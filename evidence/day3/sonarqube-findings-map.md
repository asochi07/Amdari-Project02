# SonarQube SAST Scan — Complete Findings Map
# SecureFlow DevSecOps Pipeline — Stage 2 Evidence
# Project: asochi07_Amdari-Project02 | Total Findings: 29

---

## FINDINGS SUMMARY

| Metric | Count |
|---|---|
| Total Issues | 29 |
| BLOCKER | 4 |
| MAJOR | 24 |
| MINOR | 1 |
| Vulnerabilities | 19 |
| Code Smells | 10 |

---

## GATE POLICY APPLIED

| Severity | Gate Behaviour | Count | Action |
|---|---|---|---|
| BLOCKER | HARD-FAIL | 4 | Pipeline blocks — DevSecOps or AppSec must fix before merge |
| MAJOR | SOFT-FAIL | 24 | Routed to AppSec via PR comment — pipeline continues |
| MINOR | SOFT-FAIL | 1 | Routed to AppSec via PR comment — pipeline continues |

---

## BLOCKER FINDINGS — HARD-FAIL (4 findings)

These findings will hard-fail the pipeline. They must be resolved or
formally excepted before any merge is permitted.

| # | Message | File | Line | Rule | Vuln ID | Owner |
|---|---|---|---|---|---|---|
| 1 | Avoid binding the application to all network interfaces | services/auth-service/app.py | 162 | python:S8392 | IV-02, IV-07 | AppSec |
| 2 | Avoid binding the application to all network interfaces | services/frontend/app.py | 185 | python:S8392 | IV-02, IV-07 | AppSec |
| 3 | Avoid binding the application to all network interfaces | services/transaction-service/app.py | 201 | python:S8392 | IV-02, IV-07 | AppSec |
| 4 | Make sure granting all privileges is safe here | infra/terraform/modules/iam/main.tf | 52 | terraform:S6302 | IV-08 | DevSecOps |

### Detail on Each BLOCKER

**Findings 1, 2, 3 — Binding to 0.0.0.0 (all interfaces)**
All three Flask services use `app.run(host="0.0.0.0")` which binds
the application to every available network interface including
external-facing ones. In a production Kubernetes pod this means
the service is reachable from outside its intended network boundary.
This is an AppSec code fix — replace with a specific interface or
use an environment variable.
- Vulnerability IDs: IV-02 (database exposed on host network — same
  pattern), IV-07 (no network segmentation)
- Owner: AppSec team — ROUTED, not remediated by DevSecOps

**Finding 4 — IAM AdministratorAccess (BLOCKER)**
The Terraform IAM module grants all privileges (`"*"`) to the IAM
role. This directly matches vulnerability IV-08 from the SecureFlow
index — overly permissive IAM policies. This is a DevSecOps-owned
finding and will be remediated in Week 2 Day 8 by scoping the IAM
policy to least-privilege managed policies.
- Vulnerability ID: IV-08
- Owner: DevSecOps — REMEDIATE in Week 2

---

## MAJOR FINDINGS — SOFT-FAIL, ROUTED TO APPSEC

### GitHub Actions Workflow Permissions (3 findings)

| # | Message | File | Line | Rule | Type |
|---|---|---|---|---|---|
| 5 | Move this read permission from workflow level to job level | .github/workflows/devsecops-pipeline.yml | 22 | githubactions:S8264 | VULNERABILITY |
| 6 | Move this read permission from workflow level to job level | .github/workflows/devsecops-pipeline.yml | 23 | githubactions:S8264 | VULNERABILITY |
| 7 | Move this write permission from workflow level to job level | .github/workflows/devsecops-pipeline.yml | 24 | githubactions:S8233 | VULNERABILITY |

**What this means:** The `permissions` block we added to Stage 1 is
set at the workflow level, meaning ALL jobs inherit those permissions.
SonarQube correctly flags this — best practice is to set permissions
at the individual job level so each job only has exactly the
permissions it needs.

**This is actually about our own pipeline file.** This is a
DevSecOps-owned finding. Fix by moving permissions into each job:

```yaml
# Instead of this at workflow level:
permissions:
  contents: read
  pull-requests: read
  issues: write

# Add to each job that needs it:
jobs:
  secret-scan:
    permissions:
      contents: read
      issues: write    # Only secret-scan needs to create issues
    steps:
      ...

  sast-scan:
    permissions:
      contents: read   # Only needs to read code
    steps:
      ...
```

---

### Kubernetes Manifest Findings (9 findings)

| # | Message | File | Line | Rule | Vuln ID | Type |
|---|---|---|---|---|---|---|
| 8 | Use specific version tag instead of latest | infra/kubernetes/base/auth-service.yaml | 20 | kubernetes:S6596 | CK-06 | CODE_SMELL |
| 9 | Ensure enabling privileged mode is safe here | infra/kubernetes/base/auth-service.yaml | 40 | kubernetes:S6428 | CK-04 | VULNERABILITY |
| 10 | Make sure enabling privilege escalation is safe here | infra/kubernetes/base/auth-service.yaml | 41 | kubernetes:S6430 | CK-04 | VULNERABILITY |
| 11 | Use specific version tag instead of latest | infra/kubernetes/base/frontend.yaml | 18 | kubernetes:S6596 | CK-06 | CODE_SMELL |
| 12 | Ensure enabling privileged mode is safe here | infra/kubernetes/base/frontend.yaml | 25 | kubernetes:S6428 | CK-04 | VULNERABILITY |
| 13 | Make sure enabling privilege escalation is safe here | infra/kubernetes/base/frontend.yaml | 26 | kubernetes:S6430 | CK-04 | VULNERABILITY |
| 14 | Use specific version tag instead of latest | infra/kubernetes/base/transaction-service.yaml | 18 | kubernetes:S6596 | CK-06 | CODE_SMELL |
| 15 | Ensure enabling privileged mode is safe here | infra/kubernetes/base/transaction-service.yaml | 37 | kubernetes:S6428 | CK-04 | VULNERABILITY |
| 16 | Make sure enabling privilege escalation is safe here | infra/kubernetes/base/transaction-service.yaml | 38 | kubernetes:S6430 | CK-04 | VULNERABILITY |

**Ownership: DevSecOps — REMEDIATE in Week 2 Day 7**
These are all Kubernetes manifest misconfigurations in the DevSecOps
domain:
- CK-04: Privileged containers and privilege escalation enabled
- CK-06: Image:latest tags without digest pinning
All three services have the same set of issues — they will all be
fixed together during Kubernetes hardening in Week 2.

---

### Terraform RDS Findings (4 findings)

| # | Message | File | Line | Rule | Vuln ID | Type |
|---|---|---|---|---|---|---|
| 17 | Omitting backup_retention_period results in short backup duration | infra/terraform/modules/rds/main.tf | 35 | terraform:S6364 | IV-09 | VULNERABILITY |
| 18 | Make sure that using unencrypted RDS DB Instances is safe here | infra/terraform/modules/rds/main.tf | 47 | terraform:S6303 | IV-09 | VULNERABILITY |
| 19 | Omitting backup_retention_period results in short backup duration | infra/terraform/modules/rds/main.tf | 55 | terraform:S6364 | IV-09 | VULNERABILITY |
| 20 | Make sure that using unencrypted RDS DB Instances is safe here | infra/terraform/modules/rds/main.tf | 67 | terraform:S6303 | IV-09 | VULNERABILITY |

**Ownership: DevSecOps — REMEDIATE in Week 2 Day 8**
Both RDS instances (auth-db and transaction-db) are configured
without encryption and without backup retention periods. This maps
to IV-09 — unencrypted storage. Will be remediated in Terraform
IaC hardening by enabling `storage_encrypted = true` and setting
`backup_retention_period = 7`.

---

### VPC Security Group Finding (1 finding)

| # | Message | File | Line | Rule | Vuln ID | Type |
|---|---|---|---|---|---|---|
| 21 | Restrict IP addresses authorized to access administration services | infra/terraform/modules/vpc/main.tf | 60 | terraform:S6321 | IV-10 | VULNERABILITY |

**Ownership: DevSecOps — REMEDIATE in Week 2 Day 8**
Security group allows overly broad ingress rules — 0.0.0.0/0 access
to administration ports. Will be restricted to specific CIDR ranges
during Terraform IaC hardening.

---

### Python Application Code Findings (11 findings)

| # | Message | File | Line | Rule | Vuln ID | Type | Owner |
|---|---|---|---|---|---|---|---|
| 22 | "password" detected here — review hard-coded credential | services/auth-service/app.py | 22 | python:S2068 | IV-03, AV-07 | VULNERABILITY | DevSecOps (secret) + AppSec (code) |
| 23 | Specify HTTP methods this route should accept | services/auth-service/app.py | 35 | python:S6965 | AV-04 | CODE_SMELL | AppSec |
| 24 | "password" detected here — review hard-coded credential | services/transaction-service/app.py | 19 | python:S2068 | IV-03 | VULNERABILITY | DevSecOps (secret) + AppSec (code) |
| 25 | Specify HTTP methods this route should accept | services/transaction-service/app.py | 47 | python:S6965 | TV-06 | CODE_SMELL | AppSec |
| 26 | Specify HTTP methods this route should accept | services/frontend/app.py | 75 | python:S6965 | FV-05 | CODE_SMELL | AppSec |
| 27 | Specify HTTP methods this route should accept | services/frontend/app.py | 129 | python:S6965 | FV-05 | CODE_SMELL | AppSec |
| 28 | Specify HTTP methods this route should accept | services/frontend/app.py | 173 | python:S6965 | FV-05 | CODE_SMELL | AppSec |
| 29 | Specify HTTP methods this route should accept | services/frontend/app.py | 179 | python:S6965 | FV-05 | CODE_SMELL | AppSec |

**On findings 22 and 24 — Hard-coded password detection:**
SonarQube detected password variable assignments in the Python
source files. These are the DB_PASSWORD environment variable
reads in the application code. The credential itself lives in
docker-compose.yml and .env (already caught by Gitleaks Stage 1).
The code-level fix is to remove the fallback hardcoded value and
require the environment variable to be set — AppSec code fix.

**On findings 23, 25, 26, 27, 28, 29 — HTTP method specification:**
Flask routes defined without explicit `methods=["GET","POST"]`
declarations accept all HTTP methods by default. This is a code
quality issue that can lead to unintended method acceptance — for
example a GET endpoint accidentally accepting POST requests.
Owner: AppSec team.

---

## MINOR FINDINGS (1 finding)

| # | Message | File | Line | Rule | Type | Owner |
|---|---|---|---|---|---|---|
| 30 | Restrict IP addresses authorized to access admin services | infra/terraform/modules/vpc/main.tf | 60 | terraform:S6321 | VULNERABILITY | DevSecOps |

---

## COMPLETE FINDINGS MAP BY VULNERABILITY INDEX

| Vulnerability ID | Description | SonarQube Findings | Owner | Week 2 Action |
|---|---|---|---|---|
| IV-02 | Database/service exposed on host network | Findings 1, 2, 3 | AppSec | Route — code fix |
| IV-03 | Secrets in environment variables | Findings 22, 24 | DevSecOps + AppSec | Vault migration Day 6 |
| IV-07 | No network segmentation | Findings 1, 2, 3 | AppSec | Route — code fix |
| IV-08 | Overly permissive IAM | Finding 4 | DevSecOps | Remediate Day 8 |
| IV-09 | Unencrypted storage | Findings 17, 18, 19, 20 | DevSecOps | Remediate Day 8 |
| IV-10 | EKS nodes / overly broad security groups | Finding 21 | DevSecOps | Remediate Day 8 |
| AV-07 | Hardcoded JWT/credentials | Findings 22, 24 | DevSecOps + AppSec | Vault migration Day 6 |
| AV-04 | No rate limiting / missing method specs | Finding 23 | AppSec | Route |
| CK-04 | Privileged containers | Findings 9, 10, 12, 13, 15, 16 | DevSecOps | Remediate Day 7 |
| CK-06 | Latest image tag usage | Findings 8, 11, 14 | DevSecOps | Remediate Day 7 |
| TV-06 | Missing CSRF / method protection | Finding 25 | AppSec | Route |
| FV-05 | CSRF on transfer form / method specs | Findings 26, 27, 28, 29 | AppSec | Route |

---

## NOTABLE OBSERVATION — SQL INJECTION NOT DETECTED

SonarQube did NOT flag SQL injection (AV-01, AV-02) in this scan.
This is an important real-world lesson:

SAST tools have limited coverage. SonarQube's Python rules did not
detect the string concatenation SQL injection pattern in auth-service.
This is why DAST (OWASP ZAP in Stage 7) is also required — it will
detect the SQL injection by actually attempting the attack against
the running application. Neither tool alone provides complete
coverage. Both are needed.

This finding should be documented in the gate policy as a known
SAST limitation and a reason why the ZAP stage is mandatory.

---

## PIPELINE GATE RESULT FOR STAGE 2

| Finding Category | Count | Gate Action |
|---|---|---|
| BLOCKER findings | 4 | HARD-FAIL — pipeline blocked |
| MAJOR findings (DevSecOps-owned) | 12 | Will be remediated Week 2 |
| MAJOR findings (AppSec-owned) | 12 | Soft-fail — routed to AppSec |
| MINOR findings | 1 | Soft-fail — routed to AppSec |

**Current pipeline status:** Stage 1 is already hard-failing on
committed secrets. Once Stage 1 is remediated in Week 2, Stage 2
will hard-fail on the 4 BLOCKER findings. Both must be resolved
before the pipeline can reach Stage 3.