#!/bin/bash

set -e  # Exit immediately on error

# Default values for container UID/GID
CONTAINER_UID="${PLUGIN_CONTAINER_UID:-1000}"
CONTAINER_GID="${PLUGIN_CONTAINER_GID:-1000}"

# Ensure PLUGIN_CONTAINER is set
if [[ -z "${PLUGIN_CONTAINER}" ]]; then
  echo "Error: 'container' setting is required but it was not provided."
  exit 1
fi

# Handle Docker authentication
DOCKER_AUTHENTICATION=""
[ -n "${PLUGIN_REGISTRY_USER}" ] && DOCKER_AUTHENTICATION+="-Djib.to.auth.username=${PLUGIN_REGISTRY_USER} "
[ -n "${PLUGIN_REGISTRY_PASS}" ] && DOCKER_AUTHENTICATION+="-Djib.to.auth.password=${PLUGIN_REGISTRY_PASS}"

# Process extra JIB options: remove commas and convert to space-separated string
EXTRA_JIB_OPTIONS=""
if [[ -n "${PLUGIN_EXTRA_JIB_OPTIONS}" ]]; then
  EXTRA_JIB_OPTIONS="${PLUGIN_EXTRA_JIB_OPTIONS//,/ }"
fi

# Run Maven JIB build
mvn jib:build \
        -Djib.to.image="${PLUGIN_CONTAINER}" \
        -Djib.container.user="${CONTAINER_UID}:${CONTAINER_GID}" \
        -Djib.extraDirectories.paths='/jib-files' \
        -Djib.extraDirectories.permissions='/app/entrypoint.sh'='555' \
        -Djib.container.entrypoint="/app/entrypoint.sh" \
        ${DOCKER_AUTHENTICATION} \
        ${EXTRA_JIB_OPTIONS}