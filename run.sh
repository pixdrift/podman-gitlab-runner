#!/usr/bin/env bash

currentDir="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
# shellcheck source=base.sh
source "${currentDir}"/base.sh

# podman cp to work around podman exec bug with pipes in EL8 shipped version
if ! (podman cp --pause=false "${1}" "${CONTAINER_ID}:/tmp" && \
      podman exec -i "${CONTAINER_ID}" /bin/bash /tmp/$(basename "${1}"))
then
    # Exit using the variable, to make the build as failure in GitLab CI.
    exit "$BUILD_FAILURE_EXIT_CODE"
fi
