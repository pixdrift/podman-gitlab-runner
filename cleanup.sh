#!/usr/bin/env bash

TMPDIR=$(pwd)

currentDir="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
# shellcheck source=base.sh
source "${currentDir}"/base.sh

echo "Deleting container ${CONTAINER_ID}"

podman kill "${CONTAINER_ID}"
podman rm "${CONTAINER_ID}"

# Try to remove all old containers, images, networks
podman system prune --force

# Delete leftover files in /tmp
rm -r "${TMPDIR}"

exit 0
