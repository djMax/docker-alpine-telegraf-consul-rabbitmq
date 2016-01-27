# Inspired by https://github.com/gonkulator/alpine-rmq/blob/master/Dockerfile
FROM djmax/alpine-telegraf-consul

MAINTAINER Max Metral <max@pyralis.com>

ENV         RABBITMQ_HOME=/srv/rabbitmq_server-3.6.0 \
            PLUGINS_DIR=/srv/rabbitmq_server-3.6.0/plugins \
            ENABLED_PLUGINS_FILE=/srv/rabbitmq_server-3.6.0/etc/rabbitmq/enabled_plugins \
            RABBITMQ_MNESIA_BASE=/var/lib/rabbitmq \
            TELEGRAF_PLUGINS="url=\"http://localhost:15672\"\nusername=\"guest\"\npassword=\"guest\""

COPY        ssl.config /srv/rabbitmq_server-3.6.0/etc/rabbitmq/
COPY        standard.config /srv/rabbitmq_server-3.6.0/etc/rabbitmq/
COPY        run_rabbitmq.sh /etc/service/rabbitmq/run
COPY        rabbitmq.json /etc/consul.d/

RUN         echo "Etc/UTC" > /etc/timezone && \
            chmod a+x /etc/service/rabbitmq/run && apk add --update curl tar xz bash && \
            echo "http://dl-4.alpinelinux.org/alpine/edge/main" >> /etc/apk/repositories && \
            echo "http://dl-4.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories && \
            echo "http://dl-4.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories && \
            apk add erlang erlang erlang-mnesia erlang-public-key erlang-crypto erlang-ssl \
                erlang-sasl erlang-asn1 erlang-inets erlang-os-mon erlang-xmerl erlang-eldap \
                erlang-syntax-tools --update-cache --allow-untrusted && \
            cd /srv && \
            curl -Lv -o /srv/rabbitmq-server-generic-unix-3.6.0.tar.xz \
              https://github.com/rabbitmq/rabbitmq-server/releases/download/rabbitmq_v3_6_0/rabbitmq-server-generic-unix-3.6.0.tar.xz && \
            tar -xvf rabbitmq-server-generic-unix-3.6.0.tar.xz && \
            rm -f rabbitmq-server-generic-unix-3.6.0.tar.xz && \
            touch /srv/rabbitmq_server-3.6.0/etc/rabbitmq/enabled_plugins && \
            /srv/rabbitmq_server-3.6.0/sbin/rabbitmq-plugins enable --offline rabbitmq_management && \
            apk del --purge tar xz && rm -Rf /var/cache/apk/*

EXPOSE      5671/tcp 5672/tcp 15672/tcp 15671/tcp
VOLUME      /var/lib/rabbitmq