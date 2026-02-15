# Release Process

## Versioning
- Use semantic version tags: `vMAJOR.MINOR.PATCH`.
- Example: `v1.0.0`.

## Automated flow (recommended)
Run from repository root:

```bash
./scripts/create-release.sh
```

This command:
1. Runs static/shell checks.
2. Auto-selects the next version from latest tag (default patch bump).
3. Generates:
   - `release-notes/v<x.y.z>.md`
   - version section in `CHANGELOG.md`
4. Commits generated changelog files if needed.
5. Creates an annotated tag (`-s` signed by default).
6. Builds release artifacts in `dist/`:
   - `gigabyte-ecfan-v<x.y.z>.tar.gz`
   - `SHA256SUMS-v<x.y.z>`
   - `SHA256SUMS-v<x.y.z>.asc` (when GPG signing available)
7. Pushes the tag.
8. Creates the GitHub release and uploads assets.

## Bump control
- Patch (default):
  - `./scripts/create-release.sh`
- Minor:
  - `./scripts/create-release.sh --bump minor`
- Major:
  - `./scripts/create-release.sh --bump major`
- Explicit version:
  - `./scripts/create-release.sh --version 1.2.3`

## Useful options
- Unsigned tag:
  - `./scripts/create-release.sh --no-sign`
- Draft release:
  - `./scripts/create-release.sh --draft`
- Skip publishing (prepare locally only):
  - `./scripts/create-release.sh --skip-push --skip-gh-release`

- Auto-confirm (no interactive prompt):
  - `./scripts/create-release.sh --yes`

## Changelog generation only
If you only want notes/changelog updates:

```bash
./scripts/generate-changelog.sh <x.y.z>
```
