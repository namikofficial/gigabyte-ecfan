# gigabyte-ecfan

Linux kernel module that exposes Gigabyte Embedded Controller (EC) fan telemetry via `hwmon`.
This project is intentionally monitoring-only (tach + observed PWM) and does not write fan curves.

## Compatibility Matrix
| Hardware | OS | Kernel | NVIDIA Driver Stack | Status | Notes |
| --- | --- | --- | --- | --- | --- |
| Gigabyte G5 MF5 | Pop!_OS 24.04 | `6.18.7-76061807-generic` | Proprietary driver | Verified | Post-boot module load required |

Policy:
- Do not assume compatibility on unlisted hardware/kernels.
- Treat unlisted environments as experimental until validated.

## Safety model
- No module autoload at boot.
- No udev-triggered module loading.
- Module is installed through DKMS only.
- Module is loaded post-boot by a systemd service.
- Service is installed disabled by default.

This avoids early boot ACPI/EC interactions that can deadlock with GPU init on some kernel/NVIDIA combinations.

## Repository layout
- `gigabyte_ec_fan.c`: kernel module source
- `Makefile`: local build and DKMS build entrypoint
- `dkms.conf`: DKMS package definition
- `scripts/install.sh`: production install script (root)
- `scripts/uninstall.sh`: clean rollback script (root)
- `systemd/ec-fanmon.service.template`: deferred-load service template
- `CONTRIBUTING.md`: contribution workflow and standards
- `SECURITY.md`: vulnerability reporting and support policy
- `docs/DEPLOYMENT.md`: deployment and kernel-update runbook
- `docs/TROUBLESHOOTING.md`: failure signatures and rollback steps
- `docs/PUBLISHING.md`: GitHub publication steps
- `docs/RELEASE.md`: semantic release/tag/checksum process
- `release-notes/`: versioned release notes for GitHub releases

## Local build (non-DKMS)
Requirements:
- Kernel headers for your running kernel
- `gcc`, `make`

```bash
make
modinfo ./gigabyte_ec_fan.ko | grep vermagic
```

## Production install (recommended)
Run from this repository root:

```bash
sudo ./scripts/install.sh --fanmon-bin /home/namik/bin/ec-fanmon
```

Optional flags:
- `--enable-service`: enable and start `ec-fanmon.service` immediately
- `--no-softdep`: skip `/etc/modprobe.d/gigabyte_ecfan.conf`

The install script:
1. Copies source into `/usr/src/gigabyte-ec-fan-1.0/`
2. Runs `dkms add/build/install`
3. Removes legacy boot autoload entries
4. Installs a post-boot service unit at `/etc/systemd/system/ec-fanmon.service`
5. Leaves service disabled unless `--enable-service` is provided

## Verification
```bash
dkms status | grep gigabyte-ec-fan
systemctl status ec-fanmon.service
systemd-analyze blame | grep -E "ec-fanmon|gpu-manager|nvidia-persistenced"
ls /sys/class/hwmon/
```

## Uninstall / rollback
```bash
sudo ./scripts/uninstall.sh
```

This removes:
- `ec-fanmon.service`
- DKMS entry (`gigabyte-ec-fan/1.0`)
- `/usr/src/gigabyte-ec-fan-1.0`
- softdep and legacy autoload files

## License
GPL-2.0-only. See `LICENSE`.
