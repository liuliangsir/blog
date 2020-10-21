FROM node:12-alpine as deploy

ENV NODE_ENV=production
ENV REPOSITORIES=/etc/apk/repositories
COPY repositories ${REPOSITORIES}

RUN apk add vips-dev fftw-dev build-base python3 python3-dev autoconf automake libtool nasm --update --no-cache \
  && rm -fR /var/cache/apk/*

WORKDIR /app

COPY ./.npmrc .
COPY ./package.json .
RUN npm install \
  && npm cache clean -f \
  && npm run info

COPY . .
RUN npm run build

FROM nginx:alpine

COPY nginx /etc/nginx/
RUN rm /usr/share/nginx/html/*
COPY --from=deploy /app/public /usr/share/nginx/html/
RUN ls /usr/share/nginx/html -l

EXPOSE 8080
HEALTHCHECK CMD [ "wget", "-q", "localhost:8080" ]
