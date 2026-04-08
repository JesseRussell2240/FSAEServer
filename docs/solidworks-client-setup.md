# SolidWorks Client Setup

## Windows Client Recommendation

Use the current stable x64 release of TortoiseSVN on each engineering workstation. It is the most practical Windows shell client for SVN working copies.

Install it from the official downloads page and include the command-line tools if you want `svn.exe` available in scripts.

## Working Copy Location

Create a dedicated local working copy outside OneDrive, Dropbox, or any synced desktop folder.

Good examples:

- `D:\CFE\2026`
- `C:\Engineering\CFE\2026`

Avoid:

- `Desktop`
- `Documents` under cloud sync
- direct network shares
- opening files straight from a browser download

## First Checkout

From File Explorer:

1. Create an empty local folder, for example `D:\CFE\2026`
2. Right-click the folder
3. Select `SVN Checkout...`
4. Use the repo URL:

```text
https://conestogaformulaelectric.ca/svn/cfe-solidworks/trunk/FormulaElectric/2026
```

5. Authenticate with your SVN username and password

## Daily Workflow

1. Right-click the working copy root and run `SVN Update`
2. Lock the file or files you intend to modify
3. Open and edit them in SolidWorks from the local working copy
4. Save locally as usual
5. Use `Check for Modifications`
6. Commit with a clear message
7. Release locks after the commit if the file is no longer in active work

## Locking Rules

The following file types should require locks:

- `*.sldprt`
- `*.sldasm`
- `*.slddrw`
- `*.step`
- `*.stp`
- `*.igs`
- `*.iges`
- `*.x_t`
- `*.x_b`
- `*.dxf`
- `*.dwg`
- `*.pdf`

The goal is simple: if the file is effectively binary or treated as a released artifact, force a lock before editing.

## Auto-Props For New Files

On Windows, TortoiseSVN uses the Subversion config file under `%APPDATA%\Subversion\config`.

Enable auto-props and add these rules:

```ini
[miscellany]
enable-auto-props = yes

[auto-props]
*.sldprt = svn:needs-lock=*
*.sldasm = svn:needs-lock=*
*.slddrw = svn:needs-lock=*
*.step = svn:needs-lock=*
*.stp = svn:needs-lock=*
*.igs = svn:needs-lock=*
*.iges = svn:needs-lock=*
*.x_t = svn:needs-lock=*
*.x_b = svn:needs-lock=*
*.dxf = svn:needs-lock=*
*.dwg = svn:needs-lock=*
*.pdf = svn:needs-lock=*
```

This handles new files going forward. Existing files still need a one-time property pass from an admin working copy.

If you have a workstation or WSL environment with the SVN command-line client installed, the repo includes a helper for that first pass:

```bash
./pi/scripts/apply_needs_lock.sh /path/to/working-copy
```

Run it from a checked-out working copy, review the property changes, then commit them once.

## Ignore Junk Files

Do not commit temporary or machine-local clutter. Ignore at least:

- `~$*`
- `*.tmp`
- `*.bak`
- `*.swp`
- `Thumbs.db`
- `Desktop.ini`

## SolidWorks-Specific Discipline

- Keep one working copy for the active car unless you have a specific reason to split it.
- Do not casually rename parts or assemblies after they are referenced across the car.
- Do not treat `tags` as working folders.
- Use `tags` for releases and `trunk` for active design.
- Keep shared vendor models and common hardware in the common libraries area so subsystems do not fork their own copies.

## Reality Check

This setup is SolidWorks-friendly, but it is not a drop-in replacement for SOLIDWORKS PDM Professional. What it gives you is:

- central history
- local working copies
- authentication
- file locking
- stable release tags

That is enough for a student team if the folder taxonomy and locking discipline are enforced.
