FROM alpine:latest AS release
RUN apk add --no-cache git

ARG GIT_REVISION_FRONTEND
ARG GIT_REPO_URL_FRONTEND

WORKDIR /root/

RUN set -ex \
  && git clone $GIT_REPO_URL_FRONTEND release -b $GIT_REVISION_FRONTEND --depth 1

FROM ember-deploy:1.13

# ember-cli-shims#0.1.1 seems to require git!?
USER root
RUN  apt-get update && apt-get install -y git --no-install-recommends && rm -r /var/lib/apt/lists/*
USER node

COPY --from=release --chown=node:node /root/release /home/node/app

RUN set -ex \
  && npm install \
  && bower install \
  && npm update caniuse-lite browserslist