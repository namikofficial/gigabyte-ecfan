#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage:
  ./scripts/generate-changelog.sh <version>

Examples:
  ./scripts/generate-changelog.sh 1.0.1
  ./scripts/generate-changelog.sh v1.0.1
USAGE
}

if [ $# -ne 1 ]; then
  usage >&2
  exit 2
fi

raw_version="$1"
version="${raw_version#v}"
tag="v${version}"
release_date="$(date -u +%Y-%m-%d)"

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${ROOT_DIR}"

notes_file="release-notes/${tag}.md"
mkdir -p release-notes

last_tag="$(git describe --tags --abbrev=0 --match 'v*' 2>/dev/null || true)"
if [ -n "${last_tag}" ]; then
  range="${last_tag}..HEAD"
else
  range="HEAD"
fi

workdir="$(mktemp -d)"
trap 'rm -rf "${workdir}"' EXIT

for c in feat fix docs refactor ci chore other; do
  : > "${workdir}/${c}.txt"
done

while IFS=$'\t' read -r sha subject; do
  [ -n "${sha}" ] || continue
  lower_subject="$(printf '%s' "${subject}" | tr '[:upper:]' '[:lower:]')"

  bucket="other"
  case "${lower_subject}" in
    feat:*|feature:* ) bucket="feat" ;;
    fix:*|hotfix:* ) bucket="fix" ;;
    docs:*|doc:* ) bucket="docs" ;;
    refactor:* ) bucket="refactor" ;;
    ci:* ) bucket="ci" ;;
    chore:*|build:*|test:* ) bucket="chore" ;;
  esac

  printf -- '- %s (%s)\n' "${subject}" "${sha}" >> "${workdir}/${bucket}.txt"
done < <(git log --no-merges --pretty=format:'%h%x09%s' "${range}")

has_entries=0
for c in feat fix docs refactor ci chore other; do
  if [ -s "${workdir}/${c}.txt" ]; then
    has_entries=1
    break
  fi
done

cat > "${notes_file}" <<EOF_NOTES
# ${tag}

Release date: ${release_date}
EOF_NOTES

if [ -n "${last_tag}" ]; then
  printf "\nChanges since \`%s\`:\n\n" "${last_tag}" >> "${notes_file}"
else
  printf '\nInitial release notes generated from repository history.\n\n' >> "${notes_file}"
fi

append_section() {
  local title="$1"
  local file="$2"
  if [ -s "${file}" ]; then
    {
      printf '## %s\n\n' "${title}"
      cat "${file}"
      printf '\n'
    } >> "${notes_file}"
  fi
}

if [ "${has_entries}" -eq 1 ]; then
  append_section "Features" "${workdir}/feat.txt"
  append_section "Fixes" "${workdir}/fix.txt"
  append_section "Documentation" "${workdir}/docs.txt"
  append_section "Refactors" "${workdir}/refactor.txt"
  append_section "CI / Tooling" "${workdir}/ci.txt"
  append_section "Maintenance" "${workdir}/chore.txt"
  append_section "Other" "${workdir}/other.txt"
else
  printf 'No user-facing changes in this range.\n' >> "${notes_file}"
fi

if ! grep -q "^## ${version} - ${release_date}$" CHANGELOG.md 2>/dev/null; then
  section_file="${workdir}/changelog_section.txt"
  {
    printf '## %s - %s\n\n' "${version}" "${release_date}"
    if [ "${has_entries}" -eq 1 ]; then
      [ -s "${workdir}/feat.txt" ] && { printf '### Features\n'; cat "${workdir}/feat.txt"; printf '\n'; }
      [ -s "${workdir}/fix.txt" ] && { printf '### Fixes\n'; cat "${workdir}/fix.txt"; printf '\n'; }
      [ -s "${workdir}/docs.txt" ] && { printf '### Documentation\n'; cat "${workdir}/docs.txt"; printf '\n'; }
      [ -s "${workdir}/refactor.txt" ] && { printf '### Refactors\n'; cat "${workdir}/refactor.txt"; printf '\n'; }
      [ -s "${workdir}/ci.txt" ] && { printf '### CI / Tooling\n'; cat "${workdir}/ci.txt"; printf '\n'; }
      [ -s "${workdir}/chore.txt" ] && { printf '### Maintenance\n'; cat "${workdir}/chore.txt"; printf '\n'; }
      [ -s "${workdir}/other.txt" ] && { printf '### Other\n'; cat "${workdir}/other.txt"; printf '\n'; }
    else
      printf -- '- No user-facing changes.\n\n'
    fi
  } > "${section_file}"

  tmp_file="${workdir}/CHANGELOG.new"
  inserted=0
  while IFS= read -r line; do
    printf '%s\n' "${line}" >> "${tmp_file}"
    if [ "${inserted}" -eq 0 ] && [ "${line}" = "## Unreleased" ]; then
      printf '\n' >> "${tmp_file}"
      cat "${section_file}" >> "${tmp_file}"
      inserted=1
    fi
  done < CHANGELOG.md

  if [ "${inserted}" -eq 1 ]; then
    mv "${tmp_file}" CHANGELOG.md
  fi
fi

echo "Generated ${notes_file} and updated CHANGELOG.md"
