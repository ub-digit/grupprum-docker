 
FROM ruby:2.4.8

RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    locales nano \
  && rm -rf /var/lib/apt/lists/* \
  && echo "en_US.UTF-8 UTF-8" > /etc/locale.gen \
  && locale-gen en_US.UTF-8 \
  && mkdir -p /usr/src/tmp

ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV RAILS_LOG_TO_STDOUT=true

WORKDIR /usr/src/app

EXPOSE 3000
#CMD ["sh", "-c", "rails server -b 0.0.0.0 -e development"]