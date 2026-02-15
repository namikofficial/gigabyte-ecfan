#!/usr/bin/env bash
set -euo pipefail

PACKAGE_NAME="${PACKAGE_NAME:-gigabyte-ec-fan}"
PACKAGE_VERSION="${PACKAGE_VERSION:-1.0}"
MODULE_NAME="${MODULE_NAME:-gigabyte_ec_fan}"

echo "Kernel: $(uname -r)"
echo

echo "[DKMS]"
dkms status | grep "${PACKAGE_NAME}" || echo "not installed"
echo

echo "[Service]"
if command -v systemctl >/dev/null 2>&1; then
  enabled_state="$(systemctl is-enabled ec-fanmon.service 2>/dev/null || true)"
  active_state="$(systemctl is-active ec-fanmon.service 2>/dev/null || true)"
  [ -n "${enabled_state}" ] || enabled_state="unknown"
  [ -n "${active_state}" ] || active_state="unknown"
  echo "enabled: ${enabled_state}"
  echo "active:  ${active_state}"
else
  echo "systemctl not available"
fi
echo

echo "[Module]"
if lsmod | awk '{print $1}' | grep -q "^${MODULE_NAME}$"; then
  echo "${MODULE_NAME} is loaded"
else
  echo "${MODULE_NAME} is not loaded"
fi
modinfo "${MODULE_NAME}" 2>/dev/null | grep -E '^(filename|vermagic):' || echo "module not found by modinfo"
echo

echo "[Autoload guards]"
for p in /etc/modules-load.d/gigabyte_ecfan.conf /etc/modules-load.d/gigabyte_ec_fan.conf; do
  if [ -e "$p" ]; then
    echo "UNSAFE present: $p"
  else
    echo "OK missing:    $p"
  fi
done

if [ -f /etc/modules ] && grep -Eq '^[[:space:]]*(gigabyte_ec_fan|gigabyte_ecfan)[[:space:]]*$' /etc/modules; then
  echo "UNSAFE entry in /etc/modules"
else
  echo "OK /etc/modules has no gigabyte_ec_fan autoload"
fi
echo

echo "[Boot ordering sample]"
if command -v systemd-analyze >/dev/null 2>&1; then
  systemd-analyze blame 2>/dev/null | grep -E "ec-fanmon|gpu-manager|nvidia-persistenced" || true
fi
