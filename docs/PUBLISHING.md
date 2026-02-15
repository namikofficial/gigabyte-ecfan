# Publishing to GitHub

## Current remote
This repository is configured with:
- `origin = git@github.com:namikofficial/gigabyte-ecfan.git`

## Push
Push feature/release branches from repository root:

```bash
git push -u origin <branch>
```

For release tags:

```bash
git push origin v<version>
```

## Guardrails in place
- Configured GitHub branch protection for `main` (see `docs/BRANCH_PROTECTION.md`).
- Use local push guard:
  - `./scripts/setup-local-guards.sh`

## Verify
```bash
git remote -v
git branch -vv
```
