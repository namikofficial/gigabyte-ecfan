# Release Process

## Versioning
- Use semantic version tags: `vMAJOR.MINOR.PATCH`.
- Example: `v1.0.0`.

## Pre-release checklist
1. Ensure CI is green on `main`.
2. Run local validation:
   - `make`
   - `bash -n scripts/*.sh`
   - `./scripts/check-static.sh`
3. Update:
   - `CHANGELOG.md`
   - `release-notes/<version>.md`
4. Confirm docs reflect current behavior.

## Signed tag workflow
1. Ensure your GPG key is configured:
   - `git config user.signingkey <KEY_ID>`
   - `git config tag.gpgSign true`
2. Create signed annotated tag:
   - `git tag -s v1.0.0 -m "Release v1.0.0"`
3. Verify signature:
   - `git tag -v v1.0.0`
4. Push branch and tags:
   - `git push origin main`
   - `git push origin v1.0.0`

## Checksums
Generate release checksums for source snapshot and key files:

```bash
mkdir -p dist

git archive --format=tar.gz --prefix=gigabyte-ecfan-v1.0.0/ v1.0.0 > dist/gigabyte-ecfan-v1.0.0.tar.gz
sha256sum dist/gigabyte-ecfan-v1.0.0.tar.gz scripts/*.sh dkms.conf Makefile gigabyte_ec_fan.c > dist/SHA256SUMS
```

Optional signature for checksums:

```bash
gpg --armor --detach-sign --output dist/SHA256SUMS.asc dist/SHA256SUMS
```

## GitHub release notes
Create a GitHub release for tag `v1.0.0` and paste contents from `release-notes/v1.0.0.md`.
Attach:
- `dist/gigabyte-ecfan-v1.0.0.tar.gz`
- `dist/SHA256SUMS`
- `dist/SHA256SUMS.asc` (if signed)
