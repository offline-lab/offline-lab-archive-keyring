#!/usr/bin/env bash
# vi: ft=bash
# shellcheck shell=bash
#
# Build the .deb package locally with a date-based version.
# Automatically runs inside Docker when executed on the host.
#
set -euo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel)"
DOCKER_IMAGE="offline-lab-archive-keyring-builder"

#
# Check if running inside a container
#
function build_local::is_container() {
    [[ -f /.dockerenv ]] || grep -qsw docker /proc/1/cgroup 2>/dev/null
}

#
# Build the docker image and re-execute this script inside it
#
function build_local::run_in_docker() {
    echo "==> Building Docker image..."
    docker build -t "${DOCKER_IMAGE}" "${REPO_ROOT}"

    echo "==> Starting build in Docker..."
    docker run --rm \
        -v "${REPO_ROOT}:/build" \
        -w /build \
        "${DOCKER_IMAGE}" \
        ./bin/build-local.sh "$@"
}

#
# Run the actual build inside the container
#
function build_local::run() {
    local version
    version="$(date +%Y.%m.%d)"

    test -f keyrings/offline-lab-archive-keyring.asc \
        || {
            echo "ERROR: keyring file missing after refresh"
            exit 1
        }

    echo "==> Setting version ${version}..."
    sed -i "1s/^offline-lab-archive-keyring ([^)]*)/offline-lab-archive-keyring (${version})/" \
        debian/changelog

    echo "==> Building package..."
    dpkg-buildpackage -us -uc -b

    mkdir -p dist
    mv ../*.deb dist/

    dh clean

    ls dist/*.deb
    echo "==> Build complete."
}

#
# Main
#
function build_local::main() {
    if build_local::is_container; then
        build_local::run
    else
        build_local::run_in_docker "$@"
    fi
}

build_local::main "$@"
