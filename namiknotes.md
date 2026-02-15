# Run This To Apply Now

1. `cd ~/kernel-modules/gigabyte_ecfan`
2. `sudo ./scripts/install.sh --fanmon-bin /home/namik/bin/ec-fanmon`
3. `./scripts/verify.sh`
4. When ready to start it: `sudo systemctl enable --now ec-fanmon.service`
5. Re-verify: `./scripts/verify.sh`
