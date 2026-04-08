#!/usr/bin/env bash
set -euo pipefail

if [[ "${EUID}" -ne 0 ]]; then
    echo "Run this script with sudo or as root."
    exit 1
fi

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd -- "${SCRIPT_DIR}/../.." && pwd)"
SOURCE_DIR="${1:-${REPO_ROOT}/site}"
TARGET_DIR="${2:-/var/www/conestogaformulaelectric.ca/current}"

if [[ ! -d "${SOURCE_DIR}" ]]; then
    echo "Source directory not found: ${SOURCE_DIR}"
    exit 1
fi

install -d -m 755 "${TARGET_DIR}"
rsync -a --delete "${SOURCE_DIR}/" "${TARGET_DIR}/"
chown -R www-data:www-data "${TARGET_DIR}"

echo "Website deployed to ${TARGET_DIR}"

