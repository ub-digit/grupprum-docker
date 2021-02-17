FROM alpine:latest AS release
RUN apk add --no-cache git

ARG GIT_REVISION_BACKEND
ARG GIT_REPO_URL_BACKEND

WORKDIR /root/

RUN set -ex \
  && git clone $GIT_REPO_URL_BACKEND release -b $GIT_REVISION_BACKEND --depth 1

FROM docker.ub.gu.se/rails:ruby-2.3.1

COPY --from=release /root/release/ /usr/src/app

RUN bundle install
CMD ["sh", "-c", "rm -f /usr/src/app/tmp/pids/server.pid && rails server -b 0.0.0.0 -e production"]