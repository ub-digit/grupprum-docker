FROM node:8

# Add the app's binaries path to $PATH
ENV PATH=/home/node/app/bin:$PATH

# Install global node dependencies and required packages
RUN set -ex \
  && npm install -g ember-cli@1.13 \
  && npm install -g bower@1.8.8 \
  && apt-get update \
  && DEBIAN_FRONTEND='noninteractive' apt-get install -y \
    git \
    --no-install-recommends && rm -r /var/lib/apt/lists/* \
  && git clone https://github.com/facebook/watchman.git -b v3.0.0 --depth 1 \
#  && apt-get remove -y --purge git \
#  && apt-get autoremove -y \
  && cd watchman \
  && ./autogen.sh \
  && ./configure --without-python \
  && make \
  && make install \
  && cd .. \
  && rm -R watchman \
  && mkdir /home/node/app \
  && chown node:node /home/node/app

WORKDIR /home/node/app
