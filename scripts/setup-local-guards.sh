#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${ROOT_DIR}"

git config core.hooksPath .githooks

echo "Local git guard installed."
echo "- Hooks path: $(git config --get core.hooksPath)"
echo "- Direct pushes to main are now blocked unless ALLOW_MAIN_PUSH=1 is set."
