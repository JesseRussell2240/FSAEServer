# Raspberry Pi Installation

These instructions assume a Raspberry Pi 5 with Raspberry Pi OS Lite 64-bit on the internal 512 GB SSD, hosted behind a normal internet router.

## 1. Base OS Setup

On first boot:

1. Update the system:

```bash
sudo apt update
sudo apt full-upgrade -y
sudo reboot
```

2. Set the basics:

```bash
sudo raspi-config
```

Use `raspi-config` to:

- set the hostname
- enable SSH
- confirm locale and keyboard
- set timezone to `America/Toronto`

3. Reserve the Pi's LAN IP address in the router so the port forwards do not break.

## 2. Clone This Repo On The Pi

Pick a durable location such as `/opt/fsae-server`:

```bash
sudo mkdir -p /opt
cd /opt
sudo git clone <your-repo-url> fsae-server
sudo chown -R "$USER":"$USER" /opt/fsae-server
cd /opt/fsae-server
```

## 3. Install The Stack

Run the install script as root:

```bash
cd /opt/fsae-server
sudo ./pi/scripts/install_pi_stack.sh
```

This installs:

- `apache2`
- `apache2-utils`
- `subversion`
- `libapache2-mod-svn`
- `certbot`
- `python3-certbot-apache`
- `curl`
- `rsync`
- `fail2ban`
- `ufw`

It also:

- creates the website and SVN parent directories
- installs the Apache virtual host template
- installs the sample SVN authz file
- enables the Apache modules needed for HTTPS and SVN

## 4. Deploy The Website

```bash
cd /opt/fsae-server
sudo ./pi/scripts/deploy_site.sh
```

Then verify Apache is serving the site on the Pi locally:

```bash
curl -I http://localhost/
```

## 5. Create SVN Users

Create at least one admin user before exposing the vault:

```bash
sudo htpasswd -c /etc/apache2/dav_svn.passwd jess
```

Add more users later without `-c`:

```bash
sudo htpasswd /etc/apache2/dav_svn.passwd alice
sudo htpasswd /etc/apache2/dav_svn.passwd bob
```

Edit `/etc/apache2/dav_svn.authz` and place users into the right groups.

## 6. Create The Repository And Vault Layout

```bash
cd /opt/fsae-server
sudo ./pi/scripts/create_svn_repo.sh cfe-solidworks
```

This creates:

- `/srv/svn/cfe-solidworks`
- standard `trunk`, `branches`, and `tags`
- the initial Formula Electric 2026 folder tree

## 7. Open The Firewall

Allow inbound web traffic:

```bash
sudo ufw allow OpenSSH
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw enable
```

If you are managing the Pi remotely, make sure SSH is still working before you disconnect.

## 8. Router Port Forwarding

In the router, forward these public ports to the Pi's reserved LAN IP:

- TCP `80`
- TCP `443`

Do not request TLS certificates until:

- the GoDaddy DNS records resolve to your public IP
- the router forwards are live
- Apache is serving the site over plain HTTP

## 9. Request HTTPS Certificates

Once DNS is live:

```bash
sudo certbot --apache -d conestogaformulaelectric.ca -d www.conestogaformulaelectric.ca
```

Certbot's own guidance is to have an existing HTTP site reachable first. After success, test:

```bash
curl -I https://conestogaformulaelectric.ca/
```

## 10. Enable Nightly Backups

Run a quick manual backup first:

```bash
sudo ./pi/scripts/backup_cfe.sh /srv/svn/cfe-solidworks
```

Then add a nightly cron job:

```bash
sudo crontab -e
```

Example:

```cron
15 2 * * * /opt/fsae-server/pi/scripts/backup_cfe.sh /srv/svn/cfe-solidworks >> /var/log/cfe-backup.log 2>&1
```

## 11. Final Smoke Test

Confirm all of these work before onboarding the team:

- `https://conestogaformulaelectric.ca/`
- `https://www.conestogaformulaelectric.ca/`
- `https://conestogaformulaelectric.ca/svn/cfe-solidworks`
- login prompt for SVN appears
- website pages load over HTTPS
- SVN repo listing is visible after authentication

## References

- [Certbot instructions generator](https://certbot.eff.org/instructions)
- [Apache Subversion quick start](https://subversion.apache.org/quick-start)
