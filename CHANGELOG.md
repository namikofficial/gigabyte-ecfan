# Changelog

## Unreleased
- Generalized docs to remove user/machine-specific values.
- Added local pre-push protection for `main` (`.githooks/pre-push`).
- Added branch protection policy documentation (`docs/BRANCH_PROTECTION.md`).

## 1.0.0 - 2026-02-15
- Added DKMS packaging (`dkms.conf`) with kernel-targeted build support.
- Added hardened install/uninstall scripts for DKMS + systemd deferred load.
- Added verification script for module/service/autoload safety checks.
- Added static-check script and CI workflow for build/lint/static validation.
- Added security policy, troubleshooting guide, and issue/PR templates.
- Added release process documentation and versioned release notes.
- Added systemd service template with post-boot modprobe strategy.
- Updated README and deployment documentation for production workflow.
