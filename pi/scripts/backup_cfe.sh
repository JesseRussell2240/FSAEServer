#!/usr/bin/env bash
set -euo pipefail

if [[ "${EUID}" -ne 0 ]]; then
    echo "Run this script with sudo or as root."
    exit 1
fi

REPO_PATH="${1:-/srv/svn/cfe-solidworks}"
SITE_ROOT="${2:-/var/www/conestogaformulaelectric.ca/current}"
BACKUP_ROOT="${3:-/var/backups/cfe}"
KEEP_DAYS="${KEEP_DAYS:-14}"

if [[ ! -d "${REPO_PATH}" ]]; then
    echo "Repository path not found: ${REPO_PATH}"
    exit 1
fi

if [[ ! -d "${SITE_ROOT}" ]]; then
    echo "Site path not found: ${SITE_ROOT}"
    exit 1
fi

if [[ "${BACKUP_ROOT}" != /var/backups/* ]]; then
    echo "Refusing to prune backups outside /var/backups"
    exit 1
fi

STAMP="$(date +%F_%H%M%S)"
DEST="${BACKUP_ROOT}/${STAMP}"
REPO_NAME="$(basename "${REPO_PATH}")"

mkdir -p "${DEST}"
svnadmin hotcopy "${REPO_PATH}" "${DEST}/${REPO_NAME}.hotcopy"
tar -czf "${DEST}/site.tgz" -C "${SITE_ROOT}" .
cp -a /etc/apache2/dav_svn.authz "${DEST}/dav_svn.authz"
cp -a /etc/apache2/sites-available/conestogaformulaelectric.ca.conf "${DEST}/apache-site.conf"
cp -a /etc/apache2/dav_svn.passwd "${DEST}/dav_svn.passwd"
chmod 600 "${DEST}/dav_svn.passwd"

find "${BACKUP_ROOT}" -mindepth 1 -maxdepth 1 -type d -mtime +"${KEEP_DAYS}" -exec rm -rf -- {} +

echo "Backup created at ${DEST}"
