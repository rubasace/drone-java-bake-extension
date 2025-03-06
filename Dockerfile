FROM alpine:3.20.2@sha256:0a4eaa0eecf5f8c050e5bba433f58c052be7587ee8af3e8b3910ef9ab5fbe9f5

ENV HOME=/root

RUN mkdir -p "${HOME}/.m2/repository"

RUN apk add --no-cache bash maven docker

RUN apk del --purge apk-tools && \
    rm -rf /sbin/apk /etc/apk /lib/apk /usr/share/apk /var/lib/apk

COPY ./entrypoint.sh .

RUN chmod 500 /entrypoint.sh

COPY ./app-entrypoint.sh /jib-files/app/entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]