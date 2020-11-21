#!/usr/bin/env bash

currentDir="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"

# shellcheck source=base.sh
source "${currentDir}"/base.sh

set -eo pipefail

# trap any error, and mark it as a system failure.
trap 'exit $SYSTEM_FAILURE_EXIT_CODE' ERR

function start_container() {
    echo "Starting container"
    if podman inspect "${CONTAINER_ID}" &>/dev/null; then
        echo 'Found old container, deleting'
        podman kill "${CONTAINER_ID}"
        podman rm "${CONTAINER_ID}"
    fi

    podman run \
        --detach \
        --interactive \
        --tty \
        --name "${CONTAINER_ID}" \
        "${PODMAN_RUN_ARGS[@]}" \
        "${IMAGE}"\
        sleep infinity
}

function install_dependencies() {
    # Copy gitlab-runner binary from the server into the container to avoid download
    podman cp --pause=false /usr/bin/gitlab-runner "${CONTAINER_ID}":/usr/bin

    # Install bash in systems with APK (e.g., Alpine)
    podman exec "${CONTAINER_ID}" sh -c 'if (! type bash && type apk) &>/dev/null; then echo "APK based distro without bash"; apk add bash; fi'

    # Install git in systems with APK (e.g., Alpine)
    podman exec "${CONTAINER_ID}" /bin/bash -c 'if (! type git && type apk) &>/dev/null; then echo "APK based distro without git"; apk add git; fi'

    # Install git in systems with APT (e.g., Debian)
    podman exec "${CONTAINER_ID}" /bin/bash -c 'if (! type git && type apt-get) &>/dev/null; then echo "APT based distro without git"; apt-get update && apt-get install --no-install-recommends -y ca-certificates git; fi'

    # Install git in systems with DNF (e.g., Fedora)
    podman exec "${CONTAINER_ID}" /bin/bash -c 'if (! type git && type dnf) &>/dev/null; then echo "DNF based distro without git"; dnf install --setopt=install_weak_deps=False --assumeyes git; fi'

    # Install git in systems with YUM (e.g., EL<=7)
    podman exec "${CONTAINER_ID}" /bin/bash -c 'if (! type git && type yum) &>/dev/null; then echo "YUM based distro without git"; yum install --assumeyes git; fi'
}

start_container
install_dependencies
