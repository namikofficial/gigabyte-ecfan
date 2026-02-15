#!/usr/bin/env bash
set -euo pipefail

PACKAGE_NAME="${PACKAGE_NAME:-gigabyte-ec-fan}"
PACKAGE_VERSION="${PACKAGE_VERSION:-1.0}"
MODULE_NAME="${MODULE_NAME:-gigabyte_ec_fan}"
ENABLE_SERVICE=0
INSTALL_SOFTDEP=1
FANMON_BIN=""

usage() {
  cat <<'EOF'
Usage: sudo ./scripts/install.sh [options]

Options:
  --fanmon-bin PATH    Path to ec-fanmon executable/script
  --enable-service     Enable and start ec-fanmon.service after install
  --no-softdep         Do not install /etc/modprobe.d/gigabyte_ecfan.conf
  -h, --help           Show this help
EOF
}

while [ $# -gt 0 ]; do
  case "$1" in
    --fanmon-bin)
      FANMON_BIN="${2:-}"
      shift 2
      ;;
    --enable-service)
      ENABLE_SERVICE=1
      shift
      ;;
    --no-softdep)
      INSTALL_SOFTDEP=0
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

if [ "$(id -u)" -ne 0 ]; then
  echo "Run as root: sudo ./scripts/install.sh [options]" >&2
  exit 1
fi

if ! command -v dkms >/dev/null 2>&1; then
  echo "dkms is required but not installed." >&2
  exit 1
fi

if ! command -v systemctl >/dev/null 2>&1; then
  echo "systemd is required but not available." >&2
  exit 1
fi

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DKMS_SRC="/usr/src/${PACKAGE_NAME}-${PACKAGE_VERSION}"
SERVICE_PATH="/etc/systemd/system/ec-fanmon.service"
SERVICE_TEMPLATE="${REPO_ROOT}/systemd/ec-fanmon.service.template"

if [ -z "${FANMON_BIN}" ]; then
  USER_HOME=""
  if [ -n "${SUDO_USER:-}" ]; then
    USER_HOME="$(getent passwd "${SUDO_USER}" | cut -d: -f6 || true)"
  fi
  if [ -z "${USER_HOME}" ] && [ -n "${USER:-}" ]; then
    USER_HOME="$(getent passwd "${USER}" | cut -d: -f6 || true)"
  fi

  if [ -x /usr/local/bin/ec-fanmon ]; then
    FANMON_BIN="/usr/local/bin/ec-fanmon"
  elif [ -n "${USER_HOME}" ] && [ -x "${USER_HOME}/bin/ec-fanmon" ]; then
    FANMON_BIN="${USER_HOME}/bin/ec-fanmon"
  else
    echo "ec-fanmon binary not found. Pass --fanmon-bin /path/to/ec-fanmon" >&2
    exit 1
  fi
fi

if [ ! -x "${FANMON_BIN}" ]; then
  echo "ec-fanmon is not executable: ${FANMON_BIN}" >&2
  exit 1
fi

if [ ! -f "${SERVICE_TEMPLATE}" ]; then
  echo "Missing service template: ${SERVICE_TEMPLATE}" >&2
  exit 1
fi

install -d "${DKMS_SRC}"
install -m 0644 "${REPO_ROOT}/gigabyte_ec_fan.c" "${DKMS_SRC}/gigabyte_ec_fan.c"
install -m 0644 "${REPO_ROOT}/Makefile" "${DKMS_SRC}/Makefile"
install -m 0644 "${REPO_ROOT}/dkms.conf" "${DKMS_SRC}/dkms.conf"
install -m 0644 "${REPO_ROOT}/README.md" "${DKMS_SRC}/README.md"

if dkms status | grep -q "^${PACKAGE_NAME}/${PACKAGE_VERSION},"; then
  dkms remove -m "${PACKAGE_NAME}" -v "${PACKAGE_VERSION}" --all || true
fi

dkms add -m "${PACKAGE_NAME}" -v "${PACKAGE_VERSION}"
dkms build -m "${PACKAGE_NAME}" -v "${PACKAGE_VERSION}"
dkms install -m "${PACKAGE_NAME}" -v "${PACKAGE_VERSION}"

rm -f /etc/modules-load.d/gigabyte_ecfan.conf
rm -f /etc/modules-load.d/gigabyte_ec_fan.conf
if [ -f /etc/modules ]; then
  sed -i -E '/^[[:space:]]*(gigabyte_ec_fan|gigabyte_ecfan)[[:space:]]*$/d' /etc/modules
fi

if [ "${INSTALL_SOFTDEP}" -eq 1 ]; then
  cat > /etc/modprobe.d/gigabyte_ecfan.conf <<'EOF'
# Keep EC module loading behind NVIDIA initialization in mixed GPU/EC setups.
softdep gigabyte_ec_fan post: nvidia
EOF
fi

sed "s|@@FANMON_BIN@@|${FANMON_BIN}|g" "${SERVICE_TEMPLATE}" > "${SERVICE_PATH}"
chmod 0644 "${SERVICE_PATH}"
systemctl daemon-reload

if [ "${ENABLE_SERVICE}" -eq 1 ]; then
  systemctl enable --now ec-fanmon.service
else
  systemctl disable --now ec-fanmon.service >/dev/null 2>&1 || true
fi

enabled_state="$(systemctl is-enabled ec-fanmon.service 2>/dev/null || true)"
[ -n "${enabled_state}" ] || enabled_state="unknown"

echo
echo "Install complete."
echo "- DKMS module: ${PACKAGE_NAME}/${PACKAGE_VERSION}"
echo "- Service file: ${SERVICE_PATH}"
echo "- Service enabled: ${enabled_state}"
echo
echo "Checks:"
echo "  dkms status | grep ${PACKAGE_NAME}"
echo "  modinfo ${MODULE_NAME} | grep vermagic"
echo "  systemctl status ec-fanmon.service"
