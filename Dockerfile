# syntax=docker/dockerfile:1

# Primera etapa: build
FROM node:slim AS build

# Crear directorio de trabajo
WORKDIR /usr/app

# Copiar archivos de la app
COPY --chown=node . .

# Instalar dependencias (sin usar GITHUB_TOKEN ni .npmrc privado)
RUN npm ci --legacy-peer-deps

# Compilar la app
RUN npm run build

# Descargar dumb-init
RUN wget -O /usr/bin/dumb-init https://github.com/Yelp/dumb-init/releases/download/v1.2.5/dumb-init_1.2.5_x86_64
RUN chmod +x /usr/bin/dumb-init

# Segunda etapa: runtime
FROM node:slim

ENV NODE_ENV=production

USER node
WORKDIR /srv/app

COPY --from=build --chown=node /usr/bin/dumb-init /usr/bin/dumb-init
COPY --from=build --chown=node /usr/app/ .

EXPOSE 3000

CMD [ "dumb-init", "node", "server/index.ts" ]