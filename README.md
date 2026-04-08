# FSAE Server

This repository is the starting point for two separate but related systems:

- A public, customer-facing static website for `conestogaformulaelectric.ca`
- A central SolidWorks-friendly CAD vault for the team, hosted on the Raspberry Pi and accessed through Apache Subversion (SVN)

The website and the CAD vault should not live in the same version-control system. The website fits Git cleanly. Live SolidWorks data does not. For the CAD side, this repo provides the server config, folder taxonomy, and operating docs for an SVN-based vault with local working copies and file locking.

## Chosen Stack

- `Apache HTTP Server`: serves the public website and the authenticated `/svn` endpoint
- `Apache Subversion`: central CAD repository with revision history, tags, and file locking
- `Certbot`: public HTTPS certificates for the site and the SVN endpoint
- `TortoiseSVN`: recommended Windows client for engineers

## Why SVN For SolidWorks

- SolidWorks files are binary and do not merge well.
- SVN supports a central working-copy model, so users keep local copies and only pull deltas with `svn update`.
- `svn:needs-lock` keeps critical CAD files read-only until a user explicitly takes a lock, which is much closer to the way CAD teams actually work than Git branching on assemblies.
- This avoids the "download a zip, edit, upload again" workflow you explicitly do not want.

## Repository Layout

- `site/`: mirrored public website content
- `docs/`: setup, operations, DNS, and client workflow documentation
- `pi/`: Raspberry Pi install scripts and Apache config templates
- `vault-template/`: canonical FSAE vault taxonomy and naming guidance

## Recommended Rollout

1. Build and verify the website locally from `site/`.
2. Bring the Raspberry Pi online with a stable LAN IP and port forwarding for `80` and `443`.
3. Point `conestogaformulaelectric.ca` and `www.conestogaformulaelectric.ca` at the Pi's public IP.
4. Install Apache, Subversion, and Certbot on the Pi with `pi/scripts/install_pi_stack.sh`.
5. Deploy the website with `pi/scripts/deploy_site.sh`.
6. Create SVN users and the initial CAD repository with `pi/scripts/create_svn_repo.sh`.
7. Have each engineer check out a local working copy with TortoiseSVN and work directly from that copy.
8. Enable nightly repository hot-copy backups even if the first backup target is still the Pi's internal SSD.

## Key Docs

- [Pi installation](docs/pi-installation.md)
- [GoDaddy DNS setup](docs/godaddy-domain-setup.md)
- [Architecture and security model](docs/architecture.md)
- [SolidWorks client setup](docs/solidworks-client-setup.md)
- [PDM workflow](docs/pdm-workflow.md)
- [SVN admin UI](docs/admin-ui.md)
- [Vault template](vault-template/README.md)

## Reference Sources

- [Reference website repo](https://github.com/conestogaFSAE/ConestogaFormulaElectric.github.io)
- [Reference live site](https://conestogafsae.github.io/ConestogaFormulaElectric.github.io/)
- [SOLIDWORKS PDM installation guide](https://files.solidworks.com/Supportfiles/PDMWorks_Ent_Installation/2023/English/Installation%20Guide.pdf)
- [Apache Subversion quick start](https://subversion.apache.org/quick-start)
- [Subversion lock reference](https://svnbook.red-bean.com/en/1.7/svn.ref.svn.c.lock.html)
- [GoDaddy DNS records help](https://www.godaddy.com/help/article/manage-dns-records-680)
- [GoDaddy A record help](https://www.godaddy.com/en-in/help/add-or-edit-an-a-record-42546)
- [Certbot instructions](https://certbot.eff.org/instructions)
- [TortoiseSVN downloads](https://tortoisesvn.net/downloads.html)
