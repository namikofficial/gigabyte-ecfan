# Installation

## Requirements
- Linux kernel headers for your running kernel
- `gcc`, `make`, `dkms`, `systemd`

## Recommended install (DKMS)
Run from repository root:

```bash
sudo ./scripts/install.sh --fanmon-bin /usr/local/bin/ec-fanmon
```

Optional flags:
- `--enable-service`: enable and start `ec-fanmon.service` immediately
- `--no-softdep`: skip `/etc/modprobe.d/gigabyte_ecfan.conf`

## What install does
1. Copies source to `/usr/src/gigabyte-ec-fan-1.0/`
2. Runs `dkms add/build/install`
3. Removes legacy boot autoload entries
4. Installs post-boot systemd unit `/etc/systemd/system/ec-fanmon.service`
5. Leaves service disabled unless explicitly enabled

## Verify install
```bash
dkms status | grep gigabyte-ec-fan
systemctl status ec-fanmon.service
ls /sys/class/hwmon/
```

## Uninstall / rollback
```bash
sudo ./scripts/uninstall.sh
```
