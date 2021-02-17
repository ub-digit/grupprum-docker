
FROM docker.ub.gu.se/ember-base:1.13

COPY docker-entrypoint.sh /usr/local/bin/

# Install global production node dependencies
RUN apt-get update \
  && apt-get install -y \
    nginx \
    --no-install-recommends && rm -r /var/lib/apt/lists/* \
  && chown -R node:node /var/log/nginx \
  && ln -sf /dev/stdout /var/log/nginx/access.log \
  && ln -sf /dev/stderr /var/log/nginx/error.log

USER node

COPY --chown=node:node nginx.conf /home/node/

EXPOSE 8080

ENTRYPOINT ["docker-entrypoint.sh"]