# SonarQube Security Hotspots — Complete Findings Map
# SecureFlow DevSecOps Pipeline — Stage 2 Evidence (Supplementary)
# Total Hotspots: 24

---

## What is a Security Hotspot?

A Security Hotspot is different from a Vulnerability. It is code that
requires manual review — SonarQube cannot automatically determine
whether it is safe or not. A human must review it and either mark it
as SAFE (with justification) or escalate it to a Vulnerability.

All 24 hotspots are AppSec-owned findings. They will be detected and
routed — not remediated by the DevSecOps engineer.

---

## HIGH PROBABILITY HOTSPOTS (6 findings)
These have the highest likelihood of being real vulnerabilities.

| # | Message | File | Line | Vuln ID | Owner |
|---|---|---|---|---|---|
| 1 | Make sure disabling CSRF protection is safe here | services/auth-service/app.py | 12 | TV-06, FV-05 | AppSec |
| 2 | Make sure disabling CSRF protection is safe here | services/frontend/app.py | 10 | FV-05 | AppSec |
| 3 | Make sure disabling CSRF protection is safe here | services/transaction-service/app.py | 10 | TV-06 | AppSec |
| 4 | Make sure allowing safe and unsafe HTTP methods is safe here | services/auth-service/app.py | 114 | AV-04 | AppSec |
| 5 | Make sure allowing safe and unsafe HTTP methods is safe here | services/frontend/app.py | 82 | FV-05 | AppSec |
| 6 | Make sure allowing safe and unsafe HTTP methods is safe here | services/frontend/app.py | 106 | FV-05 | AppSec |

### Notes on HIGH Hotspots

**Findings 1, 2, 3 — CSRF Protection Disabled**
All three services explicitly disable CSRF protection. This directly
confirms vulnerability TV-06 and FV-05 from the SecureFlow index.
Flask-WTF CSRF protection is turned off at the application level,
meaning every state-changing form and endpoint accepts requests
without a CSRF token. An attacker can trick an authenticated user
into submitting fraudulent transfers or account changes.
Owner: AppSec — fix requires adding Flask-WTF CSRF tokens to all
state-changing endpoints.

**Findings 4, 5, 6 — Unsafe HTTP Method Handling**
Routes accepting both GET and POST without restriction. Combined with
the missing CSRF protection, this means attackers can trigger
state-changing operations via GET requests which are not normally
subject to same-site cookie restrictions.
Owner: AppSec — fix requires explicit methods=["POST"] on all
state-changing routes.

---

## MEDIUM PROBABILITY HOTSPOTS (5 findings)

| # | Message | File | Line | Vuln ID | Owner |
|---|---|---|---|---|---|
| 7 | Make sure allowing public ACL/policies is safe here | infra/terraform/modules/s3/main.tf | 20 | IV-09 | DevSecOps |
| 8 | Make sure allowing public ACL/policies is safe here | infra/terraform/modules/s3/main.tf | 34 | IV-09 | DevSecOps |
| 9 | python image runs as root by default — make sure safe | services/auth-service/Dockerfile | 2 | CK-02, IV-05 | DevSecOps |
| 10 | python image runs as root by default — make sure safe | services/frontend/Dockerfile | 2 | CK-02, IV-05 | DevSecOps |
| 11 | python image runs as root by default — make sure safe | services/transaction-service/Dockerfile | 2 | CK-02, IV-05 | DevSecOps |

### Notes on MEDIUM Hotspots

**Findings 7, 8 — S3 Public ACL Policies**
Both S3 buckets in the Terraform modules have public access controls
that may allow public ACL policies to be set. This directly confirms
vulnerability IV-09 — unencrypted S3 buckets with public access
blocks disabled. DevSecOps-owned — will be remediated in Week 2
Day 8 by enabling public access blocks and encryption.

**Findings 9, 10, 11 — Containers Running as Root**
All three Dockerfiles use the base python image which defaults to
running as root. No USER directive is present in any Dockerfile.
This directly confirms CK-02 and IV-05 — containers running as root.
DevSecOps-owned — will be remediated in Week 2 Day 7 by adding
USER directive to all Dockerfiles.

---

## LOW PROBABILITY HOTSPOTS (13 findings)

| # | Message | File | Line | Vuln ID | Owner |
|---|---|---|---|---|---|
| 12 | Make sure using clear-text protocols is safe here | infra/kubernetes/base/configmap.yaml | 13 | IV-07 | DevSecOps |
| 13 | Make sure using clear-text protocols is safe here | infra/kubernetes/base/configmap.yaml | 14 | IV-07 | DevSecOps |
| 14 | Using http protocol is insecure — use https instead | services/frontend/app.py | 16 | FV-07 | AppSec |
| 15 | Using http protocol is insecure — use https instead | services/frontend/app.py | 17 | FV-07 | AppSec |
| 16 | Using http protocol is insecure — use https instead | services/transaction-service/app.py | 12 | FV-07 | AppSec |
| 17 | No bucket policy enforces HTTPS-only access | infra/terraform/modules/s3/main.tf | 7 | IV-09 | DevSecOps |
| 18 | No bucket policy enforces HTTPS-only access | infra/terraform/modules/s3/main.tf | 29 | IV-09 | DevSecOps |
| 19 | Debug feature active — deactivate before production | services/auth-service/app.py | 162 | AV-08 | AppSec |
| 20 | Debug feature active — deactivate before production | services/frontend/app.py | 185 | AV-08 | AppSec |
| 21 | Debug feature active — deactivate before production | services/transaction-service/app.py | 201 | AV-08 | AppSec |
| 22 | Make sure hashing data is safe here | services/auth-service/app.py | 32 | AV-05 | AppSec |
| 23 | S3 logging omitted — logs incomplete | infra/terraform/modules/s3/main.tf | 7 | IV-09 | DevSecOps |
| 24 | S3 logging omitted — logs incomplete | infra/terraform/modules/s3/main.tf | 29 | IV-09 | DevSecOps |

### Notes on LOW Hotspots

**Findings 12, 13 — Clear-text protocols in ConfigMap**
Service URLs in the Kubernetes ConfigMap use http:// instead of
https://. Internal service-to-service communication should use
encrypted channels. DevSecOps-owned — fix during K8s hardening.

**Findings 14, 15, 16 — HTTP instead of HTTPS**
The frontend and transaction service hardcode http:// URLs for
inter-service communication. AppSec-owned — requires code change
to use HTTPS or environment-driven URLs.

**Findings 17, 18 — No HTTPS-only S3 bucket policy**
S3 buckets lack a bucket policy enforcing HTTPS-only access,
meaning data could be accessed over unencrypted HTTP.
DevSecOps-owned — remediate with bucket policy in Week 2.

**Findings 19, 20, 21 — Debug Mode Active**
All three Flask services run with debug=True. In production this
exposes the Werkzeug interactive debugger which allows arbitrary
code execution if an attacker can trigger an error. This directly
confirms AV-08 — sensitive data in error responses. AppSec-owned.

**Finding 22 — Unsafe Hashing (MD5)**
SonarQube detected a hashing operation in auth-service at line 32.
This is the MD5 password hashing without salt — directly confirming
vulnerability AV-05. MD5 is cryptographically broken for password
storage. AppSec-owned — requires replacing with bcrypt or argon2.

**Findings 23, 24 — S3 Access Logging Disabled**
S3 buckets have no access logging configured. Without logs there is
no audit trail of who accessed what data and when. This is relevant
to the SOC 2 Type II and FCA compliance requirements documented in
Section 3.3 of the case study. DevSecOps-owned.

---

## COMBINED FINDINGS MAP — ISSUES + HOTSPOTS

| Vulnerability ID | Issues Count | Hotspots Count | Total | Owner | Week 2 Action |
|---|---|---|---|---|---|
| AV-04 | 1 | 1 | 2 | AppSec | Route |
| AV-05 | 0 | 1 | 1 | AppSec | Route |
| AV-07 | 1 | 0 | 1 | DevSecOps | Vault Day 6 |
| AV-08 | 0 | 3 | 3 | AppSec | Route |
| CK-02 | 0 | 3 | 3 | DevSecOps | Dockerfile Day 7 |
| CK-04 | 6 | 0 | 6 | DevSecOps | K8s manifest Day 7 |
| CK-06 | 3 | 0 | 3 | DevSecOps | K8s manifest Day 7 |
| FV-05 | 3 | 3 | 6 | AppSec | Route |
| FV-07 | 0 | 3 | 3 | AppSec | Route |
| IV-02 | 3 | 0 | 3 | AppSec | Route |
| IV-03 | 1 | 0 | 1 | DevSecOps | Vault Day 6 |
| IV-05 | 0 | 3 | 3 | DevSecOps | Dockerfile Day 7 |
| IV-07 | 3 | 2 | 5 | DevSecOps | NetworkPolicy Day 7 |
| IV-08 | 1 | 0 | 1 | DevSecOps | IAM Day 8 |
| IV-09 | 4 | 6 | 10 | DevSecOps | Terraform Day 8 |
| IV-10 | 1 | 0 | 1 | DevSecOps | Terraform Day 8 |
| TV-06 | 1 | 2 | 3 | AppSec | Route |

---

## KEY INSIGHT — SONARQUBE CONFIRMED AV-05 VIA HOTSPOT

SonarQube did NOT detect SQL injection (AV-01, AV-02) as expected
from SAST limitations. However it DID confirm:

- AV-05 (MD5 password hashing) via hotspot finding 22
- TV-06 (missing CSRF) via hotspot findings 1, 2, 3
- AV-08 (debug mode / sensitive error responses) via findings 19-21

This demonstrates that hotspot analysis adds meaningful coverage
beyond the standard vulnerability scan. Both the issues report AND
the hotspots report should be reviewed for complete Stage 2 coverage.

SQL injection will be detected by OWASP ZAP in Stage 7 — this
confirms why DAST is a mandatory complement to SAST.

---

## PIPELINE GATE SUMMARY — STAGE 2

| Category | Count | Gate Action |
|---|---|---|
| BLOCKER vulnerabilities | 4 | Hard-fail — blocks merge |
| MAJOR vulnerabilities (AppSec) | 12 | Soft-fail — routed to AppSec |
| MAJOR vulnerabilities (DevSecOps) | 12 | Soft-fail — remediated Week 2 |
| HIGH hotspots | 6 | Soft-fail — routed to AppSec |
| MEDIUM hotspots | 5 | Soft-fail — 3 DevSecOps, 2 AppSec |
| LOW hotspots | 13 | Soft-fail — mixed ownership |