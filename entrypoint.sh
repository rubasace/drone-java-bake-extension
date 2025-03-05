#!/bin/bash

set -e

CONTAINER_UID=1000
CONTAINER_GID=999

DOCKER_AUTHENTICATION=""
[ -n "${DOCKER_USER}" ] && DOCKER_AUTHENTICATION+="-Djib.to.auth.username=${DOCKER_USER} "
[ -n "${DOCKER_PASS}" ] && DOCKER_AUTHENTICATION+="-Djib.to.auth.password=${DOCKER_PASS}"

mvn jib:dockerBuild \
        -Djib.to.image="${CONTAINER}" \
        -Djib.container.user="${CONTAINER_UID}":"${CONTAINER_GID}" \
        -Djib.extraDirectories.paths='/jib-files' \
        -Djib.extraDirectories.permissions='/app/entrypoint.sh'='500' \
        -Djib.container.entrypoint="/app/entrypoint.sh" \
        ${DOCKER_AUTHENTICATION} \
        ${EXTRA_JIB_OPTIONS}
