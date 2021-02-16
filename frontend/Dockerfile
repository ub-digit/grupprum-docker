FROM local_ember:2.8.0

# Install global development node dependencies
RUN set -ex \
  && npm install -g check-dependencies

# Expose the app, test and live-reload ports
# 4200 devserver
# 35730 livereload
# 7357 TestEm
EXPOSE 4200 7020 35730

# --chown=0:0??
COPY docker-entrypoint.sh /usr/local/bin/
ENTRYPOINT ["docker-entrypoint.sh"]

# Change user
USER node
