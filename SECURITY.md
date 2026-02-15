# Security Policy

## Supported Versions

| Version | Status | Notes |
| --- | --- | --- |
| 1.x | Supported | Active maintenance branch |
| < 1.0.0 | Unsupported | Upgrade to latest 1.x |

## Supported Hardware/Scope
- Supported target: Gigabyte G5 MF5.
- Current validation baseline: Pop!_OS 24.04, kernel `6.18.7-76061807-generic`, NVIDIA proprietary stack.
- Do not run this driver on unsupported models unless you are actively developing and can recover from boot failures.

## Reporting a Vulnerability
Please do not open public issues for security-sensitive findings.

Preferred report paths:
1. GitHub private vulnerability report (Security Advisory) for this repository.
2. Email fallback: `namikofficial@gmail.com` with subject prefix `[gigabyte-ecfan][security]`.

Please include:
- Impact summary
- Reproduction steps
- Kernel version and distro
- Hardware model
- Relevant logs (`dmesg`, `journalctl -b`)

## Response Targets
- Initial acknowledgement: within 7 days
- Remediation plan/update: within 30 days when reproducible

## Safety Policy
This project prioritizes boot reliability over feature speed.
Changes that increase early-boot risk may be rejected.
