# Troubleshooting

## Quick rollback (safe default)
If anything looks unstable:

```bash
sudo systemctl disable --now ec-fanmon.service
sudo ./scripts/uninstall.sh
```

Reboot and confirm the system is stable before further testing.

## Failure signatures and actions

### 1) Boot delay/freeze around udev
Symptoms:
- Boot hangs with messages similar to `Timed out waiting for udev queue`.

Actions:
1. Boot fallback kernel.
2. Disable service and uninstall module stack:
   - `sudo systemctl disable --now ec-fanmon.service`
   - `sudo ./scripts/uninstall.sh`
3. Confirm no autoload files exist:
   - `ls /etc/modules-load.d | grep -E 'gigabyte_ecfan|gigabyte_ec_fan'`
4. Reboot.

### 2) Module fails to load
Symptoms:
- `modprobe gigabyte_ec_fan` fails
- `modinfo gigabyte_ec_fan` not found

Actions:
1. Verify DKMS status:
   - `dkms status | grep gigabyte-ec-fan`
2. Reinstall via DKMS:
   - `sudo ./scripts/install.sh --fanmon-bin /home/namik/bin/ec-fanmon`
3. Check kernel header availability for current kernel.

### 3) Service crash loop
Symptoms:
- `ec-fanmon.service` repeatedly restarts.

Actions:
1. Inspect logs:
   - `journalctl -u ec-fanmon.service -b --no-pager | tail -n 100`
2. Validate monitor binary path and executable bit.
3. Temporarily disable service until root cause is fixed:
   - `sudo systemctl disable --now ec-fanmon.service`

### 4) Missing hwmon entries
Symptoms:
- Expected `gigabyte_ecfan` entry not present under `/sys/class/hwmon`.

Actions:
1. Confirm module loaded:
   - `lsmod | grep gigabyte_ec_fan`
2. Check kernel log for probe errors:
   - `dmesg | grep -i gigabyte`
3. Confirm hardware model support (G5 MF5 baseline only).

## Post-fix verification

```bash
./scripts/verify.sh
systemd-analyze blame | grep -E "ec-fanmon|gpu-manager|nvidia-persistenced"
```
