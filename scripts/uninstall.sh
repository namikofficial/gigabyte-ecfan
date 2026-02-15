#!/usr/bin/env bash
set -euo pipefail

PACKAGE_NAME="${PACKAGE_NAME:-gigabyte-ec-fan}"
PACKAGE_VERSION="${PACKAGE_VERSION:-1.0}"
MODULE_NAME="${MODULE_NAME:-gigabyte_ec_fan}"
SERVICE_PATH="/etc/systemd/system/ec-fanmon.service"
DKMS_SRC="/usr/src/${PACKAGE_NAME}-${PACKAGE_VERSION}"

if [ "$(id -u)" -ne 0 ]; then
  echo "Run as root: sudo ./scripts/uninstall.sh" >&2
  exit 1
fi

if command -v systemctl >/dev/null 2>&1; then
  systemctl disable --now ec-fanmon.service >/dev/null 2>&1 || true
fi
rm -f "${SERVICE_PATH}"

rm -f /etc/modules-load.d/gigabyte_ecfan.conf
rm -f /etc/modules-load.d/gigabyte_ec_fan.conf
if [ -f /etc/modules ]; then
  sed -i -E '/^[[:space:]]*(gigabyte_ec_fan|gigabyte_ecfan)[[:space:]]*$/d' /etc/modules
fi
rm -f /etc/modprobe.d/gigabyte_ecfan.conf

if command -v modprobe >/dev/null 2>&1; then
  modprobe -r "${MODULE_NAME}" >/dev/null 2>&1 || true
fi

if command -v dkms >/dev/null 2>&1; then
  dkms remove -m "${PACKAGE_NAME}" -v "${PACKAGE_VERSION}" --all >/dev/null 2>&1 || true
fi

rm -rf "${DKMS_SRC}"

if command -v depmod >/dev/null 2>&1; then
  depmod -a || true
fi

if command -v systemctl >/dev/null 2>&1; then
  systemctl daemon-reload || true
fi

echo "Uninstall complete."
