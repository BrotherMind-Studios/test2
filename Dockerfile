# syntax=docker/dockerfile:1

# Primera etapa: build
FROM node:22-alpine AS build

# Crear directorio de trabajo
WORKDIR /usr/app

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
WORKDIR /srv/app

COPY --from=build --chown=node /usr/app/ .

EXPOSE 3000

CMD [ "node", "server/index.ts" ]