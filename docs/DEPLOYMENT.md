# Deployment Runbook

## Apply now
1. `cd ~/kernel-modules/gigabyte_ecfan`
2. `sudo ./scripts/install.sh --fanmon-bin /home/namik/bin/ec-fanmon`
3. `./scripts/verify.sh`
4. Start when ready: `sudo systemctl enable --now ec-fanmon.service`
5. Re-verify: `./scripts/verify.sh`

## Safety model
- EC module is not autoloaded during early boot.
- Service performs post-boot `modprobe` only after `multi-user.target`.
- Module installation is handled by DKMS.

## After kernel updates
1. Boot the new kernel once without forcing service changes.
2. Check DKMS state: `dkms status | grep gigabyte-ec-fan`
3. Verify module metadata: `modinfo gigabyte_ec_fan | grep vermagic`
4. Validate service and ordering:
   - `systemctl status ec-fanmon.service`
   - `systemd-analyze blame | grep -E "ec-fanmon|gpu-manager|nvidia-persistenced"`

## Rollback
- Disable and stop service:
  - `sudo systemctl disable --now ec-fanmon.service`
- Remove stack:
  - `sudo ./scripts/uninstall.sh`
