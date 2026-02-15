# Security Policy

## Supported Versions

| Version | Status | Notes |
| --- | --- | --- |
| 1.x | Supported | Active maintenance branch |
| < 1.0.0 | Unsupported | Upgrade to latest 1.x |

## Supported Scope
- This project is validated only on environments listed in `README.md` compatibility matrix.
- Do not run this driver on unlisted hardware/kernel combinations in production.

## Reporting a Vulnerability
Do not open public issues for security-sensitive findings.

Preferred report paths:
1. GitHub private vulnerability report (Security Advisory).
2. Maintainer security mailbox

Please include:
- Impact summary
- Reproduction steps
- Kernel version and distro
- Hardware model
- Relevant logs (`dmesg`, `journalctl -b`)

## Response Targets
- Initial acknowledgement: within 7 days
- Remediation update: within 30 days when reproducible

## Safety Policy
Boot reliability is prioritized over feature velocity.
Changes that increase early-boot risk may be rejected.
