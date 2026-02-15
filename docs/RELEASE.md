# Release Process

## Versioning
- Use semantic version tags: `vMAJOR.MINOR.PATCH`.
- Example: `v1.0.0`.

## Automated flow (recommended)
Run from repository root:

```bash
./scripts/create-release.sh --version <x.y.z>
```

This command:
1. Runs static/shell checks.
2. Generates:
   - `release-notes/v<x.y.z>.md`
   - version section in `CHANGELOG.md`
3. Commits generated changelog files if needed.
4. Creates an annotated tag (`-s` signed by default).
5. Builds release artifacts in `dist/`:
   - `gigabyte-ecfan-v<x.y.z>.tar.gz`
   - `SHA256SUMS-v<x.y.z>`
   - `SHA256SUMS-v<x.y.z>.asc` (when GPG signing available)
6. Pushes the tag.
7. Creates the GitHub release and uploads assets.

## Useful options
- Unsigned tag:
  - `./scripts/create-release.sh --version <x.y.z> --no-sign`
- Draft release:
  - `./scripts/create-release.sh --version <x.y.z> --draft`
- Skip publishing (prepare locally only):
  - `./scripts/create-release.sh --version <x.y.z> --skip-push --skip-gh-release`

## Changelog generation only
If you only want notes/changelog updates:

```bash
./scripts/generate-changelog.sh <x.y.z>
```
