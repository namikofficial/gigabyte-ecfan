# Deployment and Kernel Updates

## Apply now
1. `cd ~/kernel-modules/gigabyte_ecfan`
2. `sudo ./scripts/install.sh --fanmon-bin /usr/local/bin/ec-fanmon`
3. `./scripts/verify.sh`
4. Start when ready: `sudo systemctl enable --now ec-fanmon.service`
5. Re-verify: `./scripts/verify.sh`

## Safety model
- Module is not autoloaded during early boot
- Service performs post-boot `modprobe` after `multi-user.target`
- DKMS handles kernel-specific rebuild/install

## After kernel updates
1. Boot the new kernel
2. Check DKMS state:
   - `dkms status | grep gigabyte-ec-fan`
3. Check module metadata:
   - `modinfo gigabyte_ec_fan | grep vermagic`
4. Validate service state and ordering:
   - `systemctl status ec-fanmon.service`
   - `systemd-analyze blame | grep -E "ec-fanmon|gpu-manager|nvidia-persistenced"`

## Rollback
- Disable/stop service:
  - `sudo systemctl disable --now ec-fanmon.service`
- Remove module stack:
  - `sudo ./scripts/uninstall.sh`
