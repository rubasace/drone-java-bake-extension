#!/bin/bash

set -e

CONTAINER_UID=1000
CONTAINER_GID=999

mvn jib:dockerBuild \
        -s ".ci/settings.xml" \
        -Djib.to.image="${CONTAINER}" \
        -Djib.container.user="${CONTAINER_UID}":"${CONTAINER_GID}" \
        -Djib.extraDirectories.paths='/jib-files' \
        -Djib.extraDirectories.permissions='/app/entrypoint.sh'='500' \
        -Djib.container.entrypoint="/app/entrypoint.sh" \
        ${EXTRA_JIB_OPTIONS}
