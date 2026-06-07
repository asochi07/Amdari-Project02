# SecureFlow Security Gate Policy

**Document Owner:** DevSecOps Team
**Version:** 2.0
**Effective Date:** June 2026
**Last Revised:** Day 9 — post-remediation review
**Review Cycle:** Quarterly

---

## 1. Purpose

This document defines the security gate policy for the SecureFlow
DevSecOps pipeline. It establishes which security findings block a
merge, which are routed to other teams, and the process for requesting
exceptions.

## 2. Scope

This policy applies to all code merged to the main branch of the
SecureFlow repository via the GitHub Actions pipeline defined in
.github/workflows/devsecops-pipeline.yml.

## 3. Ownership Matrix

The pipeline runs six security scanners across seven stages. Each
scanner's findings are owned by a specific team.

| Scanner | Stage | Security Layer | Owner | Gate Behaviour |
|---|---|---|---|---|
| Gitleaks | 1 | Secrets in code/history | DevSecOps | Hard-fail on ANY finding |
| SonarQube | 2 | SAST (path-classified) | Split | Hard-fail DevSecOps-owned CRITICAL/BLOCKER; route app-code to AppSec |
| Trivy | 3 | Container image CVEs | DevSecOps | Hard-fail CRITICAL/HIGH |
| Trivy Config | 4 | Kubernetes manifests | DevSecOps | Hard-fail CRITICAL/HIGH |
| Checkov | 4 | Terraform IaC | DevSecOps | Hard-fail CRITICAL/HIGH |
| Cosign + SBOM | 6 | Supply chain integrity | DevSecOps | Sign on gate pass; attach SPDX SBOM |
| OWASP ZAP | 7 | Runtime behaviour (DAST) | AppSec | Soft-fail — route only |

## 4. Gate Decision Rules

### 4.1 DevSecOps-Owned Findings — HARD-FAIL

The following findings BLOCK the merge. They are the DevSecOps
engineer's responsibility to remediate:

- Any committed secret detected by Gitleaks (zero tolerance)
- Any CRITICAL or HIGH severity CVE in a container image
- Any CRITICAL or HIGH Kubernetes manifest misconfiguration
- Any CRITICAL or HIGH Terraform IaC misconfiguration
- IAM policies granting AdministratorAccess or wildcard permissions

**Rationale:** These findings are in infrastructure and configuration
layers that the DevSecOps team owns end to end. They can and must be
fixed before code ships.

### 4.2 AppSec-Owned Findings — SOFT-FAIL

The following findings are SURFACED but do NOT block the merge. They
are routed to the AppSec team via an automated intake comment:

- SonarQube application-code findings (services/ path), all severities
- All OWASP ZAP DAST findings (SQL injection, IDOR, XSS, CSRF)
- Application logic vulnerabilities

**Rationale:** These findings require application code changes,
business logic understanding, and testing that belong to the AppSec
and development teams. Blocking the pipeline on them would stall
delivery for issues the DevSecOps engineer cannot directly fix. They
are tracked and routed, never silently ignored.

### 4.3 SonarQube — Differentiated by Code Ownership

SonarQube findings are classified by the file path of each finding,
not treated uniformly:

- **DevSecOps-owned paths** (`infra/`, `.github/`) — CRITICAL or
  BLOCKER findings HARD-FAIL the pipeline. These are infrastructure
  and pipeline configuration the DevSecOps team owns and must fix.
  Example: an IAM policy misconfiguration detected in Terraform.

- **Application-code paths** (`services/`) — ALL findings, including
  CRITICAL and BLOCKER, are ROUTED to AppSec and do NOT block the
  merge. Example: an application binding to all network interfaces
  (app.run host 0.0.0.0) in service source code.

**Rationale:** A BLOCKER in infrastructure code is the DevSecOps
engineer's responsibility and can be fixed immediately. A BLOCKER in
application logic requires the development and AppSec teams, and
blocking delivery on it would stall the pipeline for issues the
DevSecOps engineer cannot directly remediate. The gate enforces this
split automatically by inspecting each finding's component path.

## 5. Exception Process

In rare cases a finding may need to be accepted temporarily — for
example a CVE with no available fix, or an AppSec finding scheduled
for a future sprint.

### 5.1 Requesting an Exception

A developer or reviewer comments on the pull request:

    /security-exception <finding-id> <justification>

For example:

    /security-exception CVE-2026-8376 No upstream fix available; perl-base
    package, accepted risk until Debian releases patch. Tracked in JIRA-1234.

### 5.2 Approval Requirements

- Exceptions for DevSecOps-owned findings require DevSecOps lead approval
- Exceptions must include a justification and a tracking ticket
- Exceptions are time-bounded — maximum 30 days, then re-evaluated
- Secrets findings (Gitleaks) are NEVER eligible for exception —
  credential rotation is always mandatory

### 5.3 Exception Audit

All exceptions are logged in the pipeline run and recorded in the
security gate comment history. A monthly review reconciles all open
exceptions against their tracking tickets.

## 6. AppSec Intake Template

When AppSec-owned findings are detected, the security gate posts a
PR comment containing this intake structure:

    ## AppSec Findings — Routed for Review

    The following findings require AppSec team attention. They do NOT
    block this merge but must be triaged.

    | Finding | Severity | File | Line | Vulnerability |
    |---|---|---|---|---|
    | [auto-populated from scanner output] |

    Intake: [link to AppSec ticketing queue]
    SLA: Triage within 5 business days

## 7. Supply Chain Integrity (Stage 6)

After all four scanner stages pass, the pipeline establishes supply
chain provenance for the container images:

- **Image signing** — each hardened image is signed with Cosign using
  a keypair held in GitHub secrets. Signatures allow downstream
  consumers to verify the image originated from this pipeline.
- **SBOM generation** — an SPDX software bill of materials is generated
  per image with Trivy, enumerating every package and version.
- **Attestation** — the SBOM is attached to the image as a Cosign
  attestation, cryptographically binding the bill of materials to the
  signed artefact.

Signing occurs ONLY after the security gate passes, so no failing
build is ever signed. This makes the signature a meaningful assertion
that the image cleared every DevSecOps-owned gate.

## 8. Policy Enforcement

This policy is enforced automatically by the security-gate job in the
pipeline. The gate cannot be bypassed except through the documented
exception process. Direct pushes to main that bypass the pipeline are
prohibited by branch protection rules.

## 9. Review and Maintenance

This policy is reviewed quarterly by the DevSecOps team and updated as
new scanners are added or ownership boundaries change.

---

## Appendix A — Revision History

| Version | Date | Change |
|---|---|---|
| 1.0 | Day 5 | Initial gate policy: ownership matrix, hard-fail vs soft-fail rules, exception process |
| 2.0 | Day 9 | Post-remediation review: SonarQube reclassified to path-based differentiated ownership (section 4.3); added Cosign/SBOM supply chain integrity (section 7); ownership matrix updated with Stage 6 |