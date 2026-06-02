# Day 4 Notes — Trivy and Checkov Stages

## 1. CVE Research

### What is a CVE?
CVE stands for Common Vulnerabilities and Exposures. It is a
standardised identifier assigned to a publicly known security
vulnerability. Each CVE has a unique ID in the format CVE-YEAR-NUMBER
for example CVE-2023-44487. CVEs are maintained by MITRE Corporation
and sponsored by the US Department of Homeland Security.

### What is CVSS?
CVSS stands for Common Vulnerability Scoring System. It is a
numerical score from 0.0 to 10.0 that measures the severity of a
vulnerability. The score considers factors including:
- Attack Vector: can it be exploited remotely or only locally?
- Attack Complexity: how difficult is exploitation?
- Privileges Required: does the attacker need an account first?
- User Interaction: does a victim need to click something?
- Impact: how much damage to confidentiality, integrity, availability?

### CVSS Severity Bands
| Score | Severity | Practical Meaning |
|---|---|---|
| 9.0 - 10.0 | CRITICAL | Remotely exploitable, no authentication, high impact |
| 7.0 - 8.9 | HIGH | Significant impact, relatively easy to exploit |
| 4.0 - 6.9 | MEDIUM | Exploitable but with conditions or limited impact |
| 0.1 - 3.9 | LOW | Difficult to exploit or minimal impact |
| 0.0 | NONE | No impact |

### What CRITICAL Means in Practice
A CRITICAL CVE typically means an attacker can remotely execute
arbitrary code, access all data, or crash the system with no
authentication required and no user interaction needed. For a
banking application container with a CRITICAL CVE, a single
HTTP request could give an attacker full control of the container
and potentially the underlying host.

### Why python:3.9-slim Has So Many CVEs
The python:3.9-slim base image is built on top of Debian Linux.
The Debian packages included in the image (OpenSSL, glibc, curl,
zlib etc.) accumulate CVEs over time as security researchers
discover vulnerabilities. Older base images are not automatically
updated. This is why pinning to a specific old version is dangerous
and why upgrading to python:3.12-slim eliminates most CVEs.