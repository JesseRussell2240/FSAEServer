# Architecture

## Goals

- Keep the public website simple and easy to deploy.
- Give the team a central CAD vault with local working copies.
- Prevent conflicting SolidWorks edits with explicit file locking.
- Keep the stack open, boring, and maintainable on a Raspberry Pi 5.

## Chosen Design

### Public web

- Static HTML/CSS/JS served by Apache from `/var/www/conestogaformulaelectric.ca/current`
- Public internet access on `https://conestogaformulaelectric.ca`

### CAD vault

- Apache Subversion repository exposed at `https://conestogaformulaelectric.ca/svn/<repo-name>`
- Engineers authenticate with username/password
- No anonymous read access
- Engineers work from local Windows working copies, not network shares and not direct web downloads

### TLS and certificates

- Certbot obtains and renews Let's Encrypt certificates for both the website and the authenticated SVN endpoint

## Why This Is Not A Full PLM

This is not trying to recreate SOLIDWORKS PDM Professional on unsupported hardware. The official SOLIDWORKS PDM server stack depends on Windows and SQL Server. On a Raspberry Pi 5, the practical open stack is:

- Apache
- Subversion
- TortoiseSVN
- disciplined folder structure
- lock-based CAD workflow

That gives you central history, tags, releases, and local working copies without building custom infrastructure that the team will have to babysit.

## Public vs Private

The website is public.

The SVN endpoint is public in the network sense, but it should still be authenticated. Do not make the CAD vault anonymous just because the server is internet-reachable. Publicly reachable plus authenticated is the right compromise for your stated constraint.

## Local Copy Model

- Each engineer keeps a local working copy, for example `D:\CFE\2026`
- Daily use is `Update -> Lock -> Edit -> Commit`
- Switching focus between subsystems does not require a full re-download; SVN only transfers deltas
- Team members can keep more than one working copy if they want a stable release copy and an active design copy

## Backups

Local working copies help with accidental user mistakes, but they are not a complete disaster-recovery backup:

- some users may only have a subset of the project
- their local copy may be stale
- local laptops are not a trusted backup target

Use the included backup script for nightly hot copies of the repository. If you later add an external SSD, point the backup output there first.

