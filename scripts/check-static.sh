#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${ROOT_DIR}"

# 1) No trailing whitespace in tracked text files.
if git grep -nI -E '[[:blank:]]+$' -- . ':!*.ko' ':!*.o' ':!*.mod.o' ':!*.cmd' ':!Module.symvers'; then
  echo "trailing whitespace detected" >&2
  exit 1
fi

# 2) Kernel module source must keep SPDX header.
if ! head -n 1 gigabyte_ec_fan.c | grep -q 'SPDX-License-Identifier'; then
  echo "missing SPDX header in gigabyte_ec_fan.c" >&2
  exit 1
fi

# 3) Ensure critical docs exist.
for f in README.md SECURITY.md docs/DEPLOYMENT.md docs/TROUBLESHOOTING.md docs/RELEASE.md docs/BRANCH_PROTECTION.md; do
  [ -f "$f" ] || { echo "missing required doc: $f" >&2; exit 1; }
done

echo "static checks passed"
