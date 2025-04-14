# syntax=docker/dockerfile:1

# Primera etapa: build
FROM node:22-alpine AS build

# Define ARG to control sourcemaps behavior
ARG INCLUDE_SOURCEMAPS=false
ARG NEWRELIC_SOURCEMAPS_BASE_URL

# Crear directorio de trabajo
WORKDIR /usr/app

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

# Conditionally run build and publish sourcemaps if INCLUDE_SOURCEMAPS is true
RUN if [ "$INCLUDE_SOURCEMAPS" = "true" ]; then \      
      --mount=type=secret,id=NEW_RELIC_API_USER_KEY \
      --mount=type=secret,id=NEW_RELIC_APP_ID \
      npm install -g @newrelic/publish-sourcemap && \
      for file in $(find .next/static/chunks -name "*.map"); do \
        js_file="${file%.map}"; \
        js_file="_${js_file#.}"; \
        base_url="${NEWRELIC_SOURCEMAPS_BASE_URL%/}/"; \
        echo "Uploading $file as ${base_url}${js_file}"; \
        publish-sourcemap "$file" "${base_url}${js_file}" \
          --apiKey=$(cat /run/secrets/NEW_RELIC_API_USER_KEY) \
          --applicationId=$(cat /run/secrets/NEW_RELIC_APP_ID); \
        # remove sourcemaps from the image
        echo "Removing $file"; \
        rm "$file"; \
      done; \      
    fi

# Segunda etapa: runtime
FROM node:22-alpine

ENV NODE_ENV=production

USER node
WORKDIR /srv/app
# WORKDIR /app

# COPY --from=build --chown=node /usr/app/ .
# Copiar solo lo necesario desde el build
# COPY --from=build /app/public ./public
# COPY --from=build /app/.next/standalone ./
# COPY --from=build /app/.next/static ./.next/static
# # COPY --from=build /app/.env ./.env
# COPY --from=build /app/package.json ./package.json
COPY --from=build --chown=node /usr/app/ .

EXPOSE 3000

CMD ["node", "server.js"]