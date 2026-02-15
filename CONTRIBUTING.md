# Contributing

## Scope
This repository is for safe, production-grade EC fan telemetry on Gigabyte laptops.
Boot safety is a hard requirement.

## Non-negotiable rules
- Do not add boot-time autoload of `gigabyte_ec_fan`.
- Do not add udev-triggered early EC access.
- Do not install `.ko` files manually into `/lib/modules`.
- Use DKMS for all installs and upgrades.

## Development flow
1. Build against the active kernel:
   - `make`
2. Validate module metadata:
   - `modinfo ./gigabyte_ec_fan.ko | grep vermagic`
3. Lint shell scripts:
   - `bash -n scripts/install.sh scripts/uninstall.sh scripts/verify.sh`
4. Keep service load deferred via `systemd/ec-fanmon.service.template`.
5. Do not push directly to `main`:
   - install local guard: `./scripts/setup-local-guards.sh`
   - use feature branches and pull requests

## Pull request checklist
- Document behavior changes in `README.md` or `docs/DEPLOYMENT.md`.
- Keep compatibility and safety assumptions explicit.
- Include rollback impact for any install/boot flow change.
