# SVN Admin UI

This is a minimal internal web interface for SVN user administration. It is intended for team admins to:

- create SVN users
- reset SVN user passwords
- assign users to the `admins`, `mechanical`, `electrical`, and `business` groups
- remove users from the passwd and authz files

It is not a public self-service portal. Do not expose it directly to the internet without an additional access control layer.

## What It Manages

- `/etc/apache2/dav_svn.passwd`
- `/etc/apache2/dav_svn.authz`

It does not replace Subversion itself. Engineers still work through TortoiseSVN and local working copies.

## Install On The Pi

From the repo root on the Pi:

```bash
cd /opt/FSAEServer
sudo bash ./pi/scripts/install_admin_ui.sh
```

Then set the admin login values:

```bash
sudo nano /etc/default/fsae-svn-admin
```

Set at least:

```ini
SVN_ADMIN_UI_PASSWORD=<strong password>
SVN_ADMIN_UI_SECRET=<long random secret>
SVN_ADMIN_UI_PORT=5050
SVN_ADMIN_UI_BASE_PATH=
```

Then start the service:

```bash
sudo systemctl start fsae-svn-admin
sudo systemctl status fsae-svn-admin --no-pager
```

## Recommended Exposure Model

Best practice is:

- bind the UI on the Pi only
- reverse proxy it only from an internal admin hostname or path
- restrict by source IP, VPN, or both

For example, proxy it only for your admin workstation or LAN. Do not put a public user-management form on the open internet.

## Quick LAN Test

On the Pi:

```bash
curl -I http://127.0.0.1:5050/login
```

You should get `200 OK`.

## Optional Nginx Reverse Proxy

If you want to route it through `RussellServer`, use a separate internal-only path or subdomain and restrict by IP. Example Nginx location:

```nginx
location /admin/svn-users/ {
    allow 192.168.1.0/24;
    deny all;

    proxy_pass http://192.168.1.3:5050/;
    proxy_http_version 1.1;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
}
```

This is intentionally LAN-scoped. If you need remote access, use a VPN or add another auth layer.

If you mount the UI under a path like `/admin/svn-users/`, set `SVN_ADMIN_UI_BASE_PATH=/admin/svn-users` in `/etc/default/fsae-svn-admin`. That keeps the generated form actions and redirects inside the reverse-proxy prefix instead of posting to `/users` at the domain root.

## Operational Notes

- The dedicated admin UI login is separate from SVN users.
- `SVN_ADMIN_UI_USER` defaults to `admin`.
- The app runs as root because it must edit `/etc/apache2/dav_svn.passwd` and `/etc/apache2/dav_svn.authz`.
- After user or group changes, Apache should read the updated files immediately. A reload is usually not required for normal auth changes, but it is safe to run one if you want:

```bash
sudo systemctl reload apache2
```
