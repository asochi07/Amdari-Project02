# Day 5 Notes — Security Gate and Week 1 Documentation

## 1. The Security Gate Pattern

### What is a Security Gate?
A security gate is a single decision point in a CI/CD pipeline that
aggregates the results of all upstream security scanners and makes
ONE consolidated pass/fail decision. Instead of each scanner blocking
independently, the gate collects every finding, applies ownership
rules, and decides whether the pipeline should proceed.

### Why Aggregate Into One Gate?
- Single source of truth — one place that decides merge eligibility
- Consistent policy — ownership rules applied uniformly
- Better developer experience — one clear comment instead of scattered
  failures across multiple jobs
- Auditability — every gate decision is logged and traceable

### Differentiated Gate Policy
The core principle of this engagement. Not all findings are equal and
not all findings belong to the same team:

DevSecOps-owned findings (secrets, container CVEs, IaC, K8s):
  → HARD-FAIL — block the merge
  → These are OUR responsibility to fix

AppSec-owned findings (SQLi, IDOR, XSS, CSRF):
  → SOFT-FAIL — surface but do not block
  → These belong to the AppSec team
  → Blocking on them would stall delivery for issues we cannot fix

### The Ownership Matrix
| Scanner | Stage | Layer | Owner | Gate |
|---|---|---|---|---|
| Gitleaks | 1 | Secrets | DevSecOps | Hard-fail any |
| SonarQube | 2 | App code SAST | AppSec (mostly) | Hard-fail CRITICAL only |
| Trivy Image | 3 | Container CVEs | DevSecOps | Hard-fail CRITICAL/HIGH |
| Trivy K8s | 4 | K8s manifests | DevSecOps | Hard-fail CRITICAL/HIGH |
| Checkov | 4 | Terraform IaC | DevSecOps | Hard-fail CRITICAL/HIGH |
| OWASP ZAP | 7 | Runtime DAST | AppSec | Soft-fail always |