# PDM Workflow

## Repository Strategy

Use one repository for live SolidWorks team data:

```text
https://conestogaformulaelectric.ca/svn/cfe-solidworks
```

Inside that repository:

- `trunk`: active design work
- `branches`: rare, admin-approved experiments only
- `tags`: release snapshots, design freezes, manufacturing releases

For CAD, daily branching is usually more trouble than value. Keep normal work on `trunk`.

## Standard User Flow

1. `SVN Update`
2. Lock what you intend to change
3. Edit from the local working copy
4. Verify the changed files and folders
5. Commit with a useful message
6. Unlock if the work is complete

## Release Flow

Use tags for real milestones, for example:

- `2026-concept-freeze`
- `2026-design-freeze-a`
- `2026-manufacturing-release-r1`
- `2026-competition-release`

Tags are read-only snapshots for traceability, not active workspaces.

## Naming Guidance

Keep file names stable, uppercase where it helps readability, and use subsystem prefixes early.

Examples:

- `CFE26-CHS-PRIMARY-STRUCTURE-001.SLDASM`
- `CFE26-SUS-FRONT-UPRIGHT-001.SLDPRT`
- `CFE26-BRK-PEDAL-BOX-001.SLDDRW`
- `CFE26-ACC-SEGMENT-02-ASSY-001.SLDASM`

Use consistent subsystem codes such as:

- `CHS`: chassis
- `SUS`: suspension
- `STR`: steering
- `BRK`: brakes
- `DRV`: drivetrain
- `COL`: cooling
- `AERO`: aero
- `ACC`: accumulator
- `LV`: low voltage
- `HV`: tractive system

## Folder Discipline

- Put active design files in `01_CAD`
- Put released drawings in `02_Drawings`
- Put manufacturing exports and CAM deliverables in `03_Manufacturing`
- Use `04_Electrical` when a subsystem has wiring, pinouts, harness, or embedded electrical details
- Put analysis outputs and calculations in `05_Analysis`
- Put supplier files and external references in `06_References`
- Freeze approved deliverables in `07_Released`
- Move old superseded material to `99_Archive`

## Permissions

Recommended authz policy:

- admins: read/write everywhere
- mechanical team: read/write in `01_Vehicle`, read in other areas
- electrical team: read/write in `02_Electrical`, read in other areas
- business team: read-only unless explicitly needed elsewhere

## What Not To Do

- do not edit directly from `tags`
- do not work from a network-mounted repository path
- do not dump unrelated files at the repo root
- do not keep separate unofficial copies of the same vendor model under multiple subsystems
- do not commit temporary exports unless they are part of a release package

