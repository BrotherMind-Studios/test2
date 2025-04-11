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