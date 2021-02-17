FROM alpine:latest AS release
RUN apk add --no-cache git

ARG GIT_REVISION_DOCKER
ARG GIT_REPO_URL_DOCKER

WORKDIR /root/

RUN set -ex \
  && git clone $GIT_REPO_URL_DOCKER release -b $GIT_REVISION_DOCKER --depth 1

FROM postgres:9.4

COPY --from=release /root/release/build/postgres/postgres.conf /etc/postgresql/postgresql.conf
