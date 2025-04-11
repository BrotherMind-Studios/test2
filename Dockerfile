# syntax=docker/dockerfile:1

# Primera etapa: build
FROM node:22-alpine AS build

# Crear directorio de trabajo
WORKDIR /app

# Copiar archivos de la app
COPY --chown=node . .

# Instalar dependencias (sin usar GITHUB_TOKEN ni .npmrc privado)
RUN npm ci --legacy-peer-deps

# Compilar la app
RUN npm run build

# Publica sourcemaps
RUN --mount=type=secret,id=NEW_RELIC_API_USER_KEY \
    --mount=type=secret,id=NEW_RELIC_APP_ID \
    npm install -g @newrelic/publish-sourcemap && \
    for file in $(find .next/static/chunks -name "*.map"); do \
      js_file="${file%.map}"; \
      echo "Uploading $file"; \
      publish-sourcemap "$file" "https://example.com${js_file#.}" \
        --apiKey=$(cat /run/secrets/NEW_RELIC_API_USER_KEY) \
        --applicationId=$(cat /run/secrets/NEW_RELIC_APP_ID); \
    done

# Segunda etapa: runtime
FROM node:22-alpine

ENV NODE_ENV=production

USER node
# WORKDIR /srv/app
WORKDIR /app

# COPY --from=build --chown=node /usr/app/ .
# Copiar solo lo necesario desde el build
COPY --from=build /app/public ./public
COPY --from=build /app/.next/standalone ./
COPY --from=build /app/.next/static ./.next/static
# COPY --from=build /app/.env ./.env
COPY --from=build /app/package.json ./package.json

EXPOSE 3000

CMD ["node", "server.js"]