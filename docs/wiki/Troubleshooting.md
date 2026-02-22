# Troubleshooting

## Quick rollback (safe default)
If the system looks unstable:

```bash
sudo systemctl disable --now ec-fanmon.service
sudo ./scripts/uninstall.sh
```

Reboot and confirm stability before retesting.

## Common failure signatures

## 1) Boot delay/freeze around udev
Symptoms:
- Boot hangs near `Timed out waiting for udev queue`

Actions:
1. Boot fallback kernel
2. Disable service and uninstall:
   - `sudo systemctl disable --now ec-fanmon.service`
   - `sudo ./scripts/uninstall.sh`
3. Confirm no autoload files:
   - `ls /etc/modules-load.d | grep -E 'gigabyte_ecfan|gigabyte_ec_fan'`
4. Reboot

## 2) Module fails to load
Symptoms:
- `modprobe gigabyte_ec_fan` fails
- `modinfo gigabyte_ec_fan` not found

Actions:
1. Check DKMS status:
   - `dkms status | grep gigabyte-ec-fan`
2. Reinstall:
   - `sudo ./scripts/install.sh --fanmon-bin /usr/local/bin/ec-fanmon`
3. Ensure kernel headers are installed

## 3) Service crash loop
Symptoms:
- `ec-fanmon.service` restarts repeatedly

Actions:
1. Inspect logs:
   - `journalctl -u ec-fanmon.service -b --no-pager | tail -n 100`
2. Validate monitor binary path and executable bit
3. Disable service until fixed:
   - `sudo systemctl disable --now ec-fanmon.service`

## 4) Missing hwmon entries
Symptoms:
- No expected `gigabyte_ecfan` entry under `/sys/class/hwmon`

Actions:
1. Check module loaded:
   - `lsmod | grep gigabyte_ec_fan`
2. Check kernel log:
   - `dmesg | grep -i gigabyte`
3. Confirm supported hardware baseline

## Post-fix verification
```bash
./scripts/verify.sh
systemd-analyze blame | grep -E "ec-fanmon|gpu-manager|nvidia-persistenced"
```
