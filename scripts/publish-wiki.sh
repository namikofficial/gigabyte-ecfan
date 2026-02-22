#!/usr/bin/env bash
set -euo pipefail

REPO="namikofficial/gigabyte-ecfan"
SRC_DIR="docs/wiki"

usage() {
  cat <<'EOF'
Usage: scripts/publish-wiki.sh [--repo OWNER/REPO] [--src DIR]

Publish markdown files from a source directory to a GitHub wiki.

Examples:
  scripts/publish-wiki.sh
  scripts/publish-wiki.sh --repo namikofficial/gigabyte-ecfan
  scripts/publish-wiki.sh --src docs/wiki
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --repo)
      REPO="${2:-}"
      shift 2
      ;;
    --src)
      SRC_DIR="${2:-}"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

if [[ -z "$REPO" ]]; then
  echo "Repository is required." >&2
  exit 2
fi

if [[ ! -d "$SRC_DIR" ]]; then
  echo "Source directory not found: $SRC_DIR" >&2
  exit 2
fi

if ! gh auth status >/dev/null 2>&1; then
  echo "GitHub CLI is not authenticated. Run: gh auth login" >&2
  exit 1
fi

if [[ "$(gh repo view "$REPO" --json hasWikiEnabled --jq .hasWikiEnabled)" != "true" ]]; then
  echo "Wiki is disabled for $REPO. Enable it first:" >&2
  echo "  gh repo edit $REPO --enable-wiki" >&2
  exit 1
fi

TMP_DIR="$(mktemp -d /tmp/wiki-publish.XXXXXX)"
trap 'rm -rf "$TMP_DIR"' EXIT

WIKI_URL="git@github.com:${REPO}.wiki.git"

if ! git clone "$WIKI_URL" "$TMP_DIR/wiki" >/dev/null 2>&1; then
  cat >&2 <<EOF
Failed to clone wiki repo: $WIKI_URL

GitHub sometimes does not create the wiki backend until the first page is created in the web UI.
One-time init:
1) Open: https://github.com/${REPO}/wiki
2) Click "Create the first page"
3) Create page title: Home
4) Re-run: scripts/publish-wiki.sh --repo ${REPO}
EOF
  exit 1
fi

cp -f "$SRC_DIR"/*.md "$TMP_DIR/wiki/"

pushd "$TMP_DIR/wiki" >/dev/null

if git diff --quiet && git diff --cached --quiet; then
  echo "No wiki changes to publish."
  exit 0
fi

git add -- ./*.md
if git diff --cached --quiet; then
  echo "No wiki markdown changes detected."
  exit 0
fi

git -c user.name="github-actions[bot]" -c user.email="41898282+github-actions[bot]@users.noreply.github.com" \
  commit -m "docs(wiki): sync from ${SRC_DIR}" >/dev/null

git push origin master >/dev/null
popd >/dev/null

echo "Wiki published: https://github.com/${REPO}/wiki"
