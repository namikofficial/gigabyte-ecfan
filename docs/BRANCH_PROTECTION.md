# Branch Protection Policy

This repository should block direct updates to `main`.

## Baseline settings for `main` (solo-maintainer safe)
- Pull request required before merge
- Required status checks: `build-and-lint` (strict)
- 0 required approvals
- Code owner review optional
- Dismiss stale approvals
- Require conversation resolution
- Enforce for admins
- Linear history required
- Force pushes disabled
- Deletions disabled
- Signed commits required

## Owner-only merge intent
For a solo-maintained repository, keep write/admin access only to the owner account.

Owner-only push restrictions are supported on organization repositories. On personal repositories,
GitHub may reject explicit restriction lists; in that case, the effective control is:
- no other write-capable collaborators
- protected `main` with required PR + checks + reviews

## Apply with gh CLI
From repository root:

```bash
./scripts/configure-branch-protection.sh namikofficial gigabyte-ecfan
```

Preview only:

```bash
./scripts/configure-branch-protection.sh --dry-run namikofficial gigabyte-ecfan
```

For stricter team mode (requires additional reviewers):

```bash
./scripts/configure-branch-protection.sh --approvals 1 --require-codeowner-reviews namikofficial gigabyte-ecfan
```
