FROM node:12-alpine as deploy

ENV NODE_ENV=production
ENV REPOSITORIES=/etc/apk/repositories
COPY repositories ${REPOSITORIES}

RUN apk add --update --no-cache python3 python3-dev gcc libpng-dev autoconf automake make g++ libtool nasm\
  && rm -fR /var/cache/apk/* \
  && npm install -g gatsby-cli

WORKDIR /app

COPY ./package.json .
RUN yarn install --frozen-lockfile --non-interactive \
  && yarn cache clean

COPY . .
RUN yarn build

FROM nginx:alpine

COPY nginx /etc/nginx/
COPY --from=deploy --chown=nginx:nginx /app/public /usr/share/nginx/html
RUN touch /var/run/nginx.pid \
  && chown nginx:nginx /var/run/nginx.pid \
  && chown -R nginx:nginx /var/cache/nginx

USER nginx

EXPOSE 8080
HEALTHCHECK CMD [ "wget", "-q", "localhost:8080" ]
