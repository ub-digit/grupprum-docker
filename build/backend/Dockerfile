FROM alpine:latest AS release
RUN apk add --no-cache git

ARG GIT_REVISION
ARG GIT_REPO_URL

WORKDIR /root/

RUN set -ex \
  #&& git clone $GIT_REPO_URL release -b $GIT_REVISION --depth 1
  && git clone https://github.com/ub-digit/grupprum-server release -b dockerize-app --depth 1

FROM local_ruby:2.4.8

COPY --from=release /root/release/ /usr/src/app
COPY secrets.yml /usr/src/app/config
COPY ./config/config_secret.yml /usr/src/app/config

#COPY ./config/secrets.yml /usr/src/app/config

RUN bundle install
CMD ["sh", "-c", "rm -f /usr/src/app/tmp/pids/server.pid && rails server -b 0.0.0.0 -e production]