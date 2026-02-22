# gigabyte-ecfan Wiki

`gigabyte-ecfan` is a Linux kernel module exposing Gigabyte EC fan telemetry via `hwmon`.

This driver is intentionally **monitoring-only**:
- Reads fan tachometer and observed PWM values
- Does not write fan curves
- Avoids early-boot autoload to reduce EC/ACPI startup risk

## Quick Start
1. Install via DKMS:
   - `sudo ./scripts/install.sh --fanmon-bin /usr/local/bin/ec-fanmon`
2. Verify:
   - `./scripts/verify.sh`
3. Enable monitoring service when ready:
   - `sudo systemctl enable --now ec-fanmon.service`

## Compatibility Baseline
- Hardware: Gigabyte G5 MF5
- OS: Pop!_OS 24.04
- Kernel: `6.18.7-76061807-generic`
- NVIDIA stack: Proprietary driver

Unlisted hardware/kernels are experimental until validated.

## Documentation
- [[Installation]]
- [[Deployment-and-Kernel-Updates]]
- [[Troubleshooting]]
- [[Development-and-Release]]
- [[FAQ]]

## Canonical Source of Truth
The repository docs are canonical and should be kept in sync with this wiki:
- `README.md`
- `docs/DEPLOYMENT.md`
- `docs/TROUBLESHOOTING.md`
- `docs/RELEASE.md`
- `SECURITY.md`
