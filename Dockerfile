# syntax=docker/dockerfile:1

# Primera etapa: build
FROM node:22-alpine AS build

# Define ARG to control sourcemaps behavior
ARG INCLUDE_SOURCEMAPS=false
ARG NEWRELIC_SOURCEMAPS_BASE_URL
ARG NEW_RELIC_APP_ID

# Crear directorio de trabajo
WORKDIR /app

# Copiar archivos de la app
COPY --chown=node . .

# install dependencies
RUN npm ci --legacy-peer-deps

# Instalar dependencias (sin usar GITHUB_TOKEN ni .npmrc privado)
# Condicional: Ejecutar build:with-sourcemaps si INCLUDE_SOURCEMAPS es true
RUN if [ "$INCLUDE_SOURCEMAPS" = "true" ]; then \
      echo "building with source maps"; \
      npm run build:with-sourcemaps; \
    else \
      echo "building without source maps"; \
      npm run build; \
    fi

# RUN --mount=type=secret,id=NEW_RELIC_API_USER_KEY \
#     --mount=type=secret,id=NEW_RELIC_APP_ID \
#     export NEW_RELIC_API_USER_KEY=$(cat /run/secrets/NEW_RELIC_API_USER_KEY) && \
#     export NEW_RELIC_APP_ID=$(cat /run/secrets/NEW_RELIC_APP_ID) && \
#     echo "NEW_RELIC_API_USER_KEY: $NEW_RELIC_API_USER_KEY" && \
#     echo "NEW_RELIC_APP_ID: $NEW_RELIC_APP_ID"

# Conditionally run build and publish sourcemaps if INCLUDE_SOURCEMAPS is true
RUN --mount=type=secret,id=NEW_RELIC_API_USER_KEY \
    export NEW_RELIC_API_USER_KEY=$(cat /run/secrets/NEW_RELIC_API_USER_KEY) && \
    if [ "$INCLUDE_SOURCEMAPS" = "true" ]; then \
      npm install -g @newrelic/publish-sourcemap && \
      for file in $(find .next/static/chunks -name "*.map"); do \
        js_file="${file%.map}"; \
        js_file="_${js_file#.}"; \
        base_url="${NEWRELIC_SOURCEMAPS_BASE_URL%/}/"; \
        echo "Uploading $file as ${base_url}${js_file}"; \
        echo "NEW_RELIC_API_USER_KEY: $NEW_RELIC_API_USER_KEY" && \
        echo "NEW_RELIC_APP_ID: $NEW_RELIC_APP_ID" && \
        echo "NEWRELIC_SOURCEMAPS_BASE_URL: $base_url" && \
        echo "Full: ${base_url}${js_file}" && \
        publish-sourcemap "$file" "${base_url}${js_file}" \
          --apiKey=$NEW_RELIC_API_USER_KEY \
          --applicationId=$NEW_RELIC_APP_ID; \
        # Eliminar sourcemaps de la imagen
        echo "Removing $file"; \
        rm "$file"; \
      done; \
    fi

# Segunda etapa: runtime
FROM node:22-alpine

ENV NODE_ENV=production

USER node
WORKDIR /app

# Copiar solo lo necesario desde el build
COPY --from=build /app/public ./public
COPY --from=build /app/.next/standalone ./
COPY --from=build /app/.next/static ./.next/static
# COPY --from=build /app/.env ./.env
COPY --from=build /app/package.json ./package.json

EXPOSE 3000

CMD ["node", "server.js"]