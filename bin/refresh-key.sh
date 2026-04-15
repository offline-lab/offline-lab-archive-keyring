#!/usr/bin/env bash
# Fetch the current signing key from repo.496.be and store it as ASCII armor.
# Run this after any key rotation, then commit the result.
set -euo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel)"

pushd "${REPO_ROOT}" >/dev/null || exit 1
mkdir -p "${REPO_ROOT}/keyrings" || exit
curl -fsSL https://repo.496.be/repo.gpg >"${REPO_ROOT}/keyrings/offline-lab-archive-keyring.asc"
echo "Key written to keyrings/offline-lab-archive-keyring.asc — commit and push."
