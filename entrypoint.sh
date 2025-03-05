#!/bin/bash

set -e

DOCKER_AUTHENTICATION=""
[ -n "${DOCKER_USER}" ] && DOCKER_AUTHENTICATION+="-Djib.to.auth.username=${DOCKER_USER} "
[ -n "${DOCKER_PASS}" ] && DOCKER_AUTHENTICATION+="-Djib.to.auth.password=${DOCKER_PASS}"

mvn jib:build \
        -Djib.to.image="${CONTAINER}" \
        -Djib.container.user="${CONTAINER_UID}":"${CONTAINER_GID}" \
        -Djib.extraDirectories.paths='/jib-files' \
        -Djib.container.entrypoint="/app/entrypoint.sh" \
        ${DOCKER_AUTHENTICATION} \
        ${EXTRA_JIB_OPTIONS}
