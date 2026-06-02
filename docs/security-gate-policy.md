# SecureFlow Security Gate Policy

**Document Owner:** DevSecOps Team
**Version:** 1.0
**Effective Date:** June 2026
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
| SonarQube | 2 | Application code (SAST) | AppSec | Hard-fail CRITICAL/BLOCKER only |
| Trivy | 3 | Container image CVEs | DevSecOps | Hard-fail CRITICAL/HIGH |
| Trivy Config | 4 | Kubernetes manifests | DevSecOps | Hard-fail CRITICAL/HIGH |
| Checkov | 4 | Terraform IaC | DevSecOps | Hard-fail CRITICAL/HIGH |
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

- SonarQube application-code findings below CRITICAL severity
- All OWASP ZAP DAST findings (SQL injection, IDOR, XSS, CSRF)
- Application logic vulnerabilities

**Rationale:** These findings require application code changes,
business logic understanding, and testing that belong to the AppSec
and development teams. Blocking the pipeline on them would stall
delivery for issues the DevSecOps engineer cannot directly fix. They
are tracked and routed, never silently ignored.

### 4.3 The Single Exception — SonarQube CRITICAL/BLOCKER

SonarQube CRITICAL or BLOCKER findings hard-fail the pipeline even
though SonarQube is primarily an AppSec tool. This is because a
CRITICAL/BLOCKER finding represents code so dangerous it should not
ship under any circumstances regardless of owner. Examples include
hardcoded credentials in source and application binding to all
network interfaces.

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

## 7. Policy Enforcement

This policy is enforced automatically by the security-gate job in the
pipeline. The gate cannot be bypassed except through the documented
exception process. Direct pushes to main that bypass the pipeline are
prohibited by branch protection rules.

## 8. Review and Maintenance

This policy is reviewed quarterly by the DevSecOps team and updated as
new scanners are added or ownership boundaries change.