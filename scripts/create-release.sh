#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage:
  ./scripts/create-release.sh --version <x.y.z> [options]

Options:
  --version <x.y.z>   Version to release (with or without leading v)
  --no-sign           Create unsigned annotated tag
  --draft             Create GitHub draft release
  --prerelease        Mark GitHub release as prerelease
  --skip-push         Do not push tag to origin
  --skip-gh-release   Do not create GitHub release
  --yes               Skip confirmation prompt

Examples:
  ./scripts/create-release.sh --version 1.0.1
  ./scripts/create-release.sh --version v1.0.1 --draft
USAGE
}

version=""
sign_tag=1
draft=0
prerelease=0
skip_push=0
skip_gh_release=0
auto_yes=0

while [ $# -gt 0 ]; do
  case "$1" in
    --version)
      version="${2:-}"
      shift 2
      ;;
    --no-sign)
      sign_tag=0
      shift
      ;;
    --draft)
      draft=1
      shift
      ;;
    --prerelease)
      prerelease=1
      shift
      ;;
    --skip-push)
      skip_push=1
      shift
      ;;
    --skip-gh-release)
      skip_gh_release=1
      shift
      ;;
    --yes)
      auto_yes=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

if [ -z "${version}" ]; then
  usage >&2
  exit 2
fi

version="${version#v}"
tag="v${version}"

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${ROOT_DIR}"

if ! command -v gh >/dev/null 2>&1; then
  echo "gh CLI is required to create GitHub releases." >&2
  exit 1
fi

if ! gh auth status >/dev/null 2>&1; then
  echo "gh is not authenticated. Run: gh auth login" >&2
  exit 1
fi

if ! git diff --quiet || ! git diff --cached --quiet; then
  echo "Working tree is not clean. Commit or stash changes first." >&2
  git status --short >&2 || true
  exit 1
fi

if git rev-parse -q --verify "refs/tags/${tag}" >/dev/null; then
  echo "Tag already exists: ${tag}" >&2
  exit 1
fi

./scripts/check-static.sh
bash -n scripts/*.sh

./scripts/generate-changelog.sh "${tag}"

if ! git diff --quiet -- CHANGELOG.md "release-notes/${tag}.md"; then
  git add CHANGELOG.md "release-notes/${tag}.md"
  git commit -m "chore(release): prepare ${tag} notes"
fi

if [ "${auto_yes}" -ne 1 ]; then
  echo "About to create release ${tag} from $(git rev-parse --short HEAD)."
  read -r -p "Continue? [y/N] " ans
  case "${ans}" in
    y|Y|yes|YES) ;;
    *) echo "Aborted."; exit 1 ;;
  esac
fi

if [ "${sign_tag}" -eq 1 ]; then
  git tag -s "${tag}" -m "Release ${tag}"
else
  git tag -a "${tag}" -m "Release ${tag}"
fi

mkdir -p dist
archive="dist/gigabyte-ecfan-${tag}.tar.gz"
checksums="dist/SHA256SUMS-${tag}"

 git archive --format=tar.gz --prefix="gigabyte-ecfan-${tag}/" "${tag}" > "${archive}"
sha256sum "${archive}" scripts/*.sh dkms.conf Makefile gigabyte_ec_fan.c > "${checksums}"

if gpg --list-secret-keys >/dev/null 2>&1; then
  gpg --armor --detach-sign --output "${checksums}.asc" "${checksums}" || true
fi

if [ "${skip_push}" -eq 0 ]; then
  git push origin "${tag}"
fi

if [ "${skip_gh_release}" -eq 0 ]; then
  args=("${tag}" "--title" "${tag}" "--notes-file" "release-notes/${tag}.md" "${archive}" "${checksums}")
  [ -f "${checksums}.asc" ] && args+=("${checksums}.asc")
  [ "${draft}" -eq 1 ] && args+=("--draft")
  [ "${prerelease}" -eq 1 ] && args+=("--prerelease")

  gh release create "${args[@]}"
fi

echo "Release flow complete for ${tag}"
