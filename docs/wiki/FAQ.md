# FAQ

## Does this module control fan speed?
No. It is monitoring-only (tach + observed PWM) and does not write fan curves.

## Why avoid early-boot autoload?
Some systems can deadlock around ACPI/EC interactions during GPU initialization. This project uses post-boot loading for safety.

## Is my laptop supported?
Only tested baseline hardware is considered verified. Unlisted models/kernels are experimental until validated.

## How do I rollback quickly?
```bash
sudo systemctl disable --now ec-fanmon.service
sudo ./scripts/uninstall.sh
```

## Where do I report bugs?
Open a GitHub issue with:
- laptop model
- distro/kernel version
- module/service logs
- exact reproduction steps
