FROM alpine:3.20.2@sha256:0a4eaa0eecf5f8c050e5bba433f58c052be7587ee8af3e8b3910ef9ab5fbe9f5

ENV HOME=/root
ENV CONTAINER_UID=1000
ENV CONTAINER_GID=999

RUN mkdir -p "${HOME}/.m2/repository"

COPY ./entrypoint.sh .

RUN chmod 500 /entrypoint.sh

COPY ./app-entrypoint.sh /jib-files/app/entrypoint.sh

# Fix vulnerabilities
RUN apk -U upgrade

RUN apk add --no-cache bash maven docker

RUN apk del --purge apk-tools && \
    rm -rf /sbin/apk /etc/apk /lib/apk /usr/share/apk /var/lib/apk

ENTRYPOINT ["/entrypoint.sh"]

