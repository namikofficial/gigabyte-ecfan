#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  ./scripts/configure-branch-protection.sh [--branch <name>] [--dry-run] [<owner> <repo>]

Examples:
  ./scripts/configure-branch-protection.sh
  ./scripts/configure-branch-protection.sh my-org my-repo
  ./scripts/configure-branch-protection.sh --branch main --dry-run
EOF
}

branch="main"
dry_run=0
owner=""
repo=""

while [ $# -gt 0 ]; do
  case "$1" in
    --branch)
      branch="${2:-}"
      shift 2
      ;;
    --dry-run)
      dry_run=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      if [ -z "${owner}" ]; then
        owner="$1"
      elif [ -z "${repo}" ]; then
        repo="$1"
      else
        echo "Unexpected argument: $1" >&2
        usage >&2
        exit 2
      fi
      shift
      ;;
  esac
done

if ! command -v gh >/dev/null 2>&1; then
  echo "gh CLI is required." >&2
  exit 1
fi

if ! gh auth status >/dev/null 2>&1; then
  echo "gh is not authenticated. Run: gh auth login" >&2
  exit 1
fi

resolve_from_gh_view() {
  local nwo
  nwo="$(gh repo view --json nameWithOwner -q .nameWithOwner 2>/dev/null || true)"
  if [ -n "${nwo}" ] && [[ "${nwo}" == */* ]]; then
    owner="${nwo%%/*}"
    repo="${nwo##*/}"
  fi
}

resolve_from_origin_url() {
  local remote_url parsed
  remote_url="$(git remote get-url origin 2>/dev/null || true)"
  if [ -z "${remote_url}" ]; then
    return 0
  fi

  parsed="$(printf '%s' "${remote_url}" | sed -E 's#^(git@github.com:|https://github.com/)##; s#\\.git$##')"
  if [[ "${parsed}" == */* ]]; then
    owner="${parsed%%/*}"
    repo="${parsed##*/}"
  fi
}

if [ -z "${owner}" ] || [ -z "${repo}" ]; then
  resolve_from_gh_view
fi

if [ -z "${owner}" ] || [ -z "${repo}" ]; then
  resolve_from_origin_url
fi

if [ -z "${owner}" ] || [ -z "${repo}" ]; then
  echo "Could not determine <owner>/<repo> automatically." >&2
  echo "Pass them explicitly: ./scripts/configure-branch-protection.sh <owner> <repo>" >&2
  exit 2
fi

check_context="${CHECK_CONTEXT:-CI / build-and-lint}"
endpoint="repos/${owner}/${repo}/branches/${branch}/protection"

payload="$(cat <<EOF
{
  "required_status_checks": {
    "strict": true,
    "contexts": ["${check_context}"]
  },
  "enforce_admins": true,
  "required_pull_request_reviews": {
    "dismiss_stale_reviews": true,
    "required_approving_review_count": 1,
    "require_code_owner_reviews": false
  },
  "restrictions": null,
  "required_linear_history": true,
  "allow_force_pushes": false,
  "allow_deletions": false,
  "required_conversation_resolution": true
}
EOF
)"

echo "Target: ${owner}/${repo}"
echo "Branch: ${branch}"

if [ "${dry_run}" -eq 1 ]; then
  echo
  echo "Dry run: would call"
  echo "  gh api --method PUT ${endpoint}"
  echo "Payload:"
  printf '%s\n' "${payload}"
  exit 0
fi

printf '%s\n' "${payload}" | gh api \
  --method PUT \
  -H "Accept: application/vnd.github+json" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  "${endpoint}" \
  --input - >/tmp/branch_protection_response.json

echo "Branch protection applied for ${owner}/${repo}:${branch}"
echo "Response saved to /tmp/branch_protection_response.json"
