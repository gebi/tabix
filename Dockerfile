FROM debian:bullseye

ENV APP_HOME /usr/src/app
ENV DEFAULT /etc/nginx/sites-enabled/default

RUN set -x && \
    apt-get update && \
    apt-get install -y --no-install-recommends nginx-full nginx libssl-dev openssl bind9-dnsutils && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

WORKDIR $APP_HOME
ADD ./docker $APP_HOME
ADD ./build /var/www/html

RUN rm $DEFAULT
RUN mv default $DEFAULT

CMD ./start.sh
