FROM alpine:3.20.2@sha256:0a4eaa0eecf5f8c050e5bba433f58c052be7587ee8af3e8b3910ef9ab5fbe9f5

ARG UID=1000
ARG GID=999

ENV MAVEN_CONFIG=/home/maven/.m2

RUN mkdir -p "$MAVEN_CONFIG" && \
    chown -R ${UID}:${GID} "$MAVEN_CONFIG"
# Fix vulnerabilities
RUN apk -U upgrade

RUN apk add --no-cache bash maven docker

RUN apk del --purge apk-tools && \
    rm -rf /templates /sbin/apk /etc/apk /lib/apk /usr/share/apk /var/lib/apk

COPY ./entrypoint.sh .

RUN chmod 500 /entrypoint.sh && \
    chown $UID:$GID /entrypoint.sh

COPY ./app-entrypoint.sh /jib-files/app/entrypoint.sh

RUN chmod 500 /jib-files/app/entrypoint.sh && \
    chown $UID:$GID /jib-files/app/entrypoint.sh

USER $UID:$GID

ENTRYPOINT ["/entrypoint.sh"]

