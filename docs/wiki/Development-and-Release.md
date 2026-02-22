# Development and Release

## Contribution flow
1. Create a feature branch from `main`
2. Make scoped changes with tests/verification
3. Run checks:
   - `./scripts/check-static.sh`
   - `./scripts/verify.sh`
4. Open PR and request review

See also:
- `CONTRIBUTING.md`
- `docs/BRANCH_PROTECTION.md`

## Release flow
- Use `scripts/create-release.sh` for semver bump, tag, changelog and release artifact flow
- Keep `release-notes/` updated for each version
- Validate reproducibility and checksums before publish

See:
- `docs/RELEASE.md`
- `docs/PUBLISHING.md`

## Security process
- Report vulnerabilities through the process in `SECURITY.md`
- Follow support policy and disclosure SLA before publishing fixes
