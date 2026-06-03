# Accepted-Risk CVE Register
# SecureFlow DevSecOps Pipeline — Day 7

## Overview
After upgrading from python:3.9-slim to python:3.12-slim, the CRITICAL
CVE count per image dropped from 5 to 2, and all HIGH CVEs were
eliminated. The two remaining CRITICAL CVEs have NO available fix.

## Accepted-Risk CVEs

| CVE | Package | CVSS | Reason for Acceptance |
|---|---|---|---|
| CVE-2026-42496 | perl-base 5.40.1-6 | 9.1 | No fixed version released by Debian. Cannot be patched. |
| CVE-2026-8376 | perl-base 5.40.1-6 | 9.8 | No fixed version released by Debian. Cannot be patched. |

## Justification
- Both CVEs are in perl-base, a transitive OS package in the Debian 13
  base image, not a direct application dependency.
- Neither has a fixed version available from the upstream Debian
  security team as of the scan date.
- The application does not invoke Perl's Archive::Tar functionality,
  so the practical exploitability in this context is low.
- These will be auto-resolved when Debian releases a patched perl-base
  and the base image is rebuilt.

## Controls
- Tracked in the pipeline exception register
- Re-evaluated every 30 days per the security gate policy
- Pipeline gate configured to allow these two specific CVE IDs via
  --ignore-unfixed OR an explicit .trivyignore entry

## Pipeline Configuration
To allow the pipeline to pass while these remain unfixed, the Trivy
stage will use --ignore-unfixed, which excludes CVEs that have no
available fix. This is a standard and defensible practice — you cannot
remediate what has no patch.