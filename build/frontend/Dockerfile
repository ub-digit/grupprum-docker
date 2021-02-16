FROM alpine:latest AS release
RUN apk add --no-cache git

ARG GIT_FRONTEND_REVISION
ARG GIT_FRONTEND_REPO_URL

WORKDIR /root/

RUN set -ex \
&& git clone https://github.com/ub-digit/grupprum release -b dockerize-app --depth 1
  #&& git clone $GIT_FRONTEND_REPO_URL release -b $GIT_FRONTEND_REVISION --depth 1

#FROM node:4.8.7

# Add the app's binaries path to $PATH
#ENV PATH=/home/node/app/bin:$PATH

# Install global node dependencies and required packages
#RUN set -ex \
#  && npm install -g ember-cli@0.2.3 \
#  && npm install -g bower@1.8.8 \
#  && apt-get updat \
#  && DEBIAN_FRONTEND='noninteractive' apt-get install -y \
#    git \
#    --no-install-recommends && rm -r /var/lib/apt/lists/* \
#  && git clone https://github.com/facebook/watchman.git -b v3.0.0 --depth 1 \
# -----  && apt-get remove -y --purge git \
# -----  && apt-get autoremove -y \
#  && cd watchman \
#  && ./autogen.sh \
#  && ./configure --without-python \
#  && make \
#  && make install \
#  && cd .. \
#  && rm -R watchman \
#  && mkdir /home/node/app \
#  && chown node:node /home/node/app

#WORKDIR /home/node/app

FROM ember-deploy:0.2.3
USER root
RUN  apt-get update && apt-get install -y git nano --no-install-recommends && rm -r /var/lib/apt/lists/*
USER node

COPY --from=release --chown=node:node /root/release /home/node/app
COPY package.json /home/node/app 
COPY environment.js /home/node/app/config
RUN set -ex \
  && npm install && bower install

# Expose the app, test and live-reload ports
# 4200 devserver
# 35730 livereload
# 7357 TestEm

# --chown=0:0??
#
# Change user

