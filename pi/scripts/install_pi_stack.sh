#!/usr/bin/env bash
set -euo pipefail

if [[ "${EUID}" -ne 0 ]]; then
    echo "Run this script with sudo or as root."
    exit 1
fi

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
PI_DIR="$(cd -- "${SCRIPT_DIR}/.." && pwd)"
DOMAIN="conestogaformulaelectric.ca"
WWW_ROOT="/var/www/${DOMAIN}/current"
SVN_ROOT="/srv/svn"
BACKUP_ROOT="/var/backups/cfe"
DAVLOCK_ROOT="/var/lib/apache2/davlock"
SITE_CONF="/etc/apache2/sites-available/${DOMAIN}.conf"
AUTHZ_FILE="/etc/apache2/dav_svn.authz"
PASSWD_FILE="/etc/apache2/dav_svn.passwd"

export DEBIAN_FRONTEND=noninteractive

apt-get update
apt-get install -y \
    apache2 \
    apache2-utils \
    certbot \
    curl \
    fail2ban \
    libapache2-mod-svn \
    python3-certbot-apache \
    rsync \
    subversion \
    ufw

mkdir -p "${WWW_ROOT}" "${SVN_ROOT}" "${BACKUP_ROOT}"
chmod 755 "${SVN_ROOT}" "${BACKUP_ROOT}"
mkdir -p "${DAVLOCK_ROOT}"
chown www-data:www-data "${DAVLOCK_ROOT}"
chmod 750 "${DAVLOCK_ROOT}"
chown -R www-data:www-data "/var/www/${DOMAIN}"

if [[ ! -f "${PASSWD_FILE}" ]]; then
    install -m 640 -o root -g www-data /dev/null "${PASSWD_FILE}"
fi

if [[ ! -f "${AUTHZ_FILE}" ]]; then
    install -m 640 -o root -g www-data "${PI_DIR}/apache/dav_svn.authz.example" "${AUTHZ_FILE}"
else
    echo "Preserving existing authz file: ${AUTHZ_FILE}"
fi

if [[ ! -f "${SITE_CONF}" ]]; then
    install -m 644 -o root -g root "${PI_DIR}/apache/conestogaformulaelectric.ca.conf" "${SITE_CONF}"
else
    echo "Preserving existing Apache site config: ${SITE_CONF}"
fi

a2enmod dav dav_svn authz_svn headers rewrite ssl
a2dissite 000-default.conf >/dev/null 2>&1 || true
a2ensite "${DOMAIN}.conf"

systemctl enable apache2 fail2ban
systemctl restart apache2

echo
echo "Base stack installed."
echo "Next steps:"
echo "  1. Deploy the website: sudo ${SCRIPT_DIR}/deploy_site.sh"
echo "  2. Create an SVN admin user: sudo htpasswd -c ${PASSWD_FILE} <username>"
echo "  3. Create the SVN repo: sudo ${SCRIPT_DIR}/create_svn_repo.sh cfe-solidworks"
echo "  4. Open ports 80 and 443 on your router and in UFW."
echo "  5. After DNS resolves, request TLS:"
echo "     sudo certbot --apache -d ${DOMAIN} -d www.${DOMAIN}"
