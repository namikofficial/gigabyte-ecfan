# Publishing to GitHub

## Current remote
This repository is configured with:
- `origin = git@github.com:namikofficial/gigabyte-ecfan.git`

## One-time GitHub repo creation
Create an empty repository on GitHub with:
- Owner: `namikofficial`
- Name: `gigabyte-ecfan`
- Visibility: your choice (public/private)
- Do not initialize with README, `.gitignore`, or license

## Push
From repository root:

```bash
git push -u origin main
```

For release tags:

```bash
git push origin --tags
```

## Verify
```bash
git remote -v
git branch -vv
```
