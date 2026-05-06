#!/usr/bin/env bash
set -euo pipefail

if [[ "${EUID}" -ne 0 ]]; then
    echo "Run this script with sudo or as root."
    exit 1
fi

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd -- "${SCRIPT_DIR}/../.." && pwd)"
APP_ROOT="/opt/fsae-svn-admin"
SERVICE_FILE="/etc/systemd/system/fsae-svn-admin.service"

apt-get update
apt-get install -y python3 python3-venv apache2-utils

mkdir -p "${APP_ROOT}"
cp -r "${REPO_ROOT}/admin-ui/." "${APP_ROOT}/"

python3 -m venv "${APP_ROOT}/.venv"
"${APP_ROOT}/.venv/bin/pip" install --upgrade pip
"${APP_ROOT}/.venv/bin/pip" install -r "${APP_ROOT}/requirements.txt"

cat > "${SERVICE_FILE}" <<'EOF'
[Unit]
Description=FSAE SVN Admin UI
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/opt/fsae-svn-admin
Environment=SVN_ADMIN_UI_USER=admin
EnvironmentFile=-/etc/default/fsae-svn-admin
ExecStart=/opt/fsae-svn-admin/.venv/bin/python /opt/fsae-svn-admin/app.py
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

if [[ ! -f /etc/default/fsae-svn-admin ]]; then
    cat > /etc/default/fsae-svn-admin <<'EOF'
SVN_ADMIN_UI_PASSWORD=change-this-before-starting
SVN_ADMIN_UI_SECRET=replace-with-a-long-random-string
SVN_ADMIN_UI_PORT=5050
# Set this if the UI is mounted under a reverse-proxy prefix, for example /admin/svn-users
SVN_ADMIN_UI_BASE_PATH=
EOF
    chmod 600 /etc/default/fsae-svn-admin
fi

systemctl daemon-reload
systemctl enable fsae-svn-admin

echo
echo "Admin UI installed."
echo "Before starting it:"
echo "  1. Edit /etc/default/fsae-svn-admin"
echo "  2. Set a strong SVN_ADMIN_UI_PASSWORD"
echo "  3. Set a long random SVN_ADMIN_UI_SECRET"
echo "Then start it:"
echo "  sudo systemctl start fsae-svn-admin"
echo
echo "Bind it behind a reverse proxy or internal-only listener. Do not expose it publicly without access controls."
