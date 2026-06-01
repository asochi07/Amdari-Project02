# Gitleaks Full History Scan — Complete Findings Map
# SecureFlow DevSecOps Pipeline — Stage 1 Evidence
# Date: June 2026 | Total Findings: 20

---

## FINDINGS FROM .env FILE
**Commit:** b99bc4ed | **Author:** Chiazor Charles Chianugor | **Date:** 2026-05-25

| # | Secret Found | File | Line | Rule ID | Vulnerability ID | Severity | Attack Risk |
|---|---|---|---|---|---|---|---|
| 1 | AWS_ACCESS_KEY_ID=AKIAIOSFODNN7EXAMPLE | .env | 15 | aws-access-token | IV-04 | CRITICAL | Full AWS cloud account compromise. Automated scanners detect AKIA pattern within minutes of public repo exposure |
| 2 | JWT_SECRET=super-secret-key-123 | .env | 35 | jwt-secret | AV-07, IV-04 | CRITICAL | Attacker can forge JWT tokens and log in as any user including admin with no valid credentials |
| 3 | SESSION_SECRET=changeme | .env | 40 | flask-secret-key | FV-03, IV-04 | CRITICAL | Attacker can forge Flask session cookies and hijack any active user session |
| 4 | AUTH_DB_PASSWORD=authpass123 | .env | 20 | db-password-env | IV-01, IV-04 | CRITICAL | Direct read and write access to all user account data in the auth database |
| 5 | TRANSACTION_DB_PASSWORD=txpass123 | .env | 26 | db-password-env | IV-01, IV-04 | CRITICAL | Direct read and write access to all transaction records |
| 6 | SONAR_TOKEN=sqp_examplesonarqubetoken... | .env | 44 | sonarqube-token | IV-04 | HIGH | Attacker can read code scan results, suppress findings, or disable security scanning entirely |

---

## FINDINGS FROM docker-compose.yml
**Commit:** 67266955 | **Author:** Dcoder21 | **Date:** 2026-04-17

| # | Secret Found | File | Line | Rule ID | Vulnerability ID | Severity | Attack Risk |
|---|---|---|---|---|---|---|---|
| 7 | JWT_SECRET: super-secret-key-123 | docker-compose.yml | 45 | jwt-secret | AV-07, IV-03 | CRITICAL | Same JWT secret as in .env — token forgery for any user account |
| 8 | SESSION_SECRET: changeme | docker-compose.yml | 69 | flask-secret-key | FV-03, IV-03 | CRITICAL | Same session secret as in .env — full session hijack capability |
| 9 | POSTGRES_PASSWORD: authpass123 | docker-compose.yml | 18 | db-password-env | IV-01, IV-03 | CRITICAL | Auth database password exposed — all user account data accessible |
| 10 | POSTGRES_PASSWORD: txpass123 | docker-compose.yml | 30 | db-password-env | IV-01, IV-03 | CRITICAL | Transaction database password exposed — all transaction records accessible |
| 11 | DB_PASSWORD: authpass123 | docker-compose.yml | 44 | db-password-env | IV-01, IV-03 | CRITICAL | Duplicate auth DB password in auth-service environment block |
| 12 | DB_PASSWORD: txpass123 | docker-compose.yml | 58 | db-password-env | IV-01, IV-03 | CRITICAL | Duplicate transaction DB password in transaction-service environment block |

---

## FINDINGS FROM VULNERABILITIES.md
**Commit:** 67266955 | **Author:** Dcoder21 | **Date:** 2026-04-17

| # | Secret Found | File | Line | Rule ID | Vulnerability ID | Severity | Notes |
|---|---|---|---|---|---|---|---|
| 13 | SECRET_KEY = 'super-secret-key-123' | VULNERABILITIES.md | 19 | flask-secret-key | AV-07, IV-03 | MEDIUM | Documentation file containing the real secret value — Gitleaks correctly flags it regardless of context |
| 14 | SESSION_SECRET='changeme' | VULNERABILITIES.md | 40 | flask-secret-key | FV-03, IV-03 | MEDIUM | Documentation file containing the real secret value — same issue as above |

> **Note on findings 13 and 14:** These are detected in the VULNERABILITIES.md documentation file
> that ships with the original upstream repository. The real secret values appear in the
> documentation text. These are valid findings — Gitleaks has no way to distinguish
> documentation from source code. These will be added to the allowlist in a later
> remediation step once the real secrets have been rotated.

---

## FINDINGS FROM infra/kubernetes/base/configmap.yaml
**Commit:** 67266955 | **Author:** Dcoder21 | **Date:** 2026-04-17

| # | Secret Found | File | Line | Rule ID | Vulnerability ID | Severity | Attack Risk |
|---|---|---|---|---|---|---|---|
| 15 | JWT_SECRET: "super-secret-key-123" | infra/kubernetes/base/configmap.yaml | 9 | jwt-secret | AV-07, CK-09 | CRITICAL | Secrets stored in Kubernetes ConfigMap in plaintext — any pod in the cluster can read them |
| 16 | SESSION_SECRET: "changeme" | infra/kubernetes/base/configmap.yaml | 10 | flask-secret-key | FV-03, CK-09 | CRITICAL | Session secret in ConfigMap — readable by any principal with namespace access |
| 17 | AUTH_DB_PASSWORD: "authpass123" | infra/kubernetes/base/configmap.yaml | 11 | db-password-env | IV-01, CK-09 | CRITICAL | Auth database password in ConfigMap — violates Kubernetes secrets best practice |
| 18 | TX_DB_PASSWORD: "txpass123" | infra/kubernetes/base/configmap.yaml | 12 | db-password-env | IV-01, CK-09 | CRITICAL | Transaction database password in ConfigMap — same violation |

> **Note on CK-09:** This file confirms vulnerability CK-09 from the SecureFlow index —
> "Secrets stored in plaintext Kubernetes ConfigMaps." ConfigMaps are not encrypted
> at rest and are accessible to any authenticated principal in the namespace.
> Remediation: migrate all secrets to HashiCorp Vault with per-service access policies (Week 2 Day 6).

---

## FINDINGS FROM infra/terraform/main.tf
**Commit:** 67266955 | **Author:** Dcoder21 | **Date:** 2026-04-17

| # | Secret Found | File | Line | Rule ID | Vulnerability ID | Severity | Attack Risk |
|---|---|---|---|---|---|---|---|
| 19 | password = "postgres" | infra/terraform/main.tf | 66 | hashicorp-tf-password | IV-01, IV-08 | CRITICAL | Hardcoded database password in Terraform infrastructure code — anyone with repo access can access the RDS instance |
| 20 | db_password = "postgres" | infra/terraform/main.tf | 66 | db-password-env | IV-01 | CRITICAL | Same finding detected by second rule — duplicate alert on same line |

> **Note on finding 20:** Findings 19 and 20 are the same secret on the same line detected
> by two different rules (hashicorp-tf-password and db-password-env). This is expected
> behaviour — the finding is real and critical regardless. Only one remediation action
> is needed: remove the hardcoded value and reference Vault or AWS Secrets Manager instead.

---

## SUMMARY BY FILE

| File | Findings | Vulnerability IDs Confirmed | Earliest Commit |
|---|---|---|---|
| .env | 6 | IV-04, AV-07, FV-03, IV-01 | b99bc4ed (2026-05-25) |
| docker-compose.yml | 6 | IV-03, AV-07, FV-03, IV-01 | 67266955 (2026-04-17) |
| VULNERABILITIES.md | 2 | AV-07, FV-03, IV-03 | 67266955 (2026-04-17) |
| infra/kubernetes/base/configmap.yaml | 4 | CK-09, AV-07, FV-03, IV-01 | 67266955 (2026-04-17) |
| infra/terraform/main.tf | 2 | IV-01, IV-08 | 67266955 (2026-04-17) |
| **TOTAL** | **20** | | |

---

## SUMMARY BY VULNERABILITY ID

| Vulnerability ID | Description       |Count| Files Affected                                  |
|-------|------------------------------|---|---------------------------------------------------|
| IV-01 | Hardcoded database passwords | 8 | .env, docker-compose.yml, configmap.yaml, main.tf |
| IV-03 | Secrets in environment variables | 6 | docker-compose.yml, VULNERABILITIES.md |
| IV-04 | Secrets committed in .env file | 6 | .env |
| AV-07 | Hardcoded JWT secret | 4 | .env, docker-compose.yml, configmap.yaml, VULNERABILITIES.md |
| FV-03 | Hardcoded session secret | 4 | .env, docker-compose.yml, configmap.yaml, VULNERABILITIES.md |
| CK-09 | Secrets in Kubernetes ConfigMaps | 4 | infra/kubernetes/base/configmap.yaml |
| IV-08 | Overly permissive infrastructure config | 1 | infra/terraform/main.tf |

---

## SUMMARY BY RULE ID

| Rule ID | Type | Findings | Source |
|---|---|---|---|
| db-password-env | Custom rule | 8 | .gitleaks.toml |
| flask-secret-key | Custom rule | 6 | .gitleaks.toml |
| jwt-secret | Custom rule | 4 | .gitleaks.toml |
| aws-access-token | Built-in rule | 1 | Gitleaks default ruleset |
| sonarqube-token | Custom rule | 1 | .gitleaks.toml |
| hashicorp-tf-password | Built-in rule | 1 | Gitleaks default ruleset |

> **Observation:** 18 out of 20 findings were caught by the 4 custom rules written in
> .gitleaks.toml. Only 2 were caught exclusively by built-in rules (AWS key and
> Terraform password). This confirms the custom rules are working correctly and are
> well-suited to the SecureFlow application stack.

---

## PIPELINE GATE RESULT

| Gate | Result | Reason |
|---|---|---|
| Stage 1 — Gitleaks | HARD-FAIL | 20 secrets found across 5 files in full Git history |
| Stage 2 — SonarQube | SKIPPED | Blocked by Stage 1 failure |
| Stage 3 — Trivy | SKIPPED | Blocked by Stage 1 failure |
| Stage 4 — Checkov | SKIPPED | Blocked by Stage 1 failure |
| Stage 5 — Security Gate | SKIPPED | Blocked by Stage 1 failure |
| Stage 6 — Image Sign | SKIPPED | Blocked by Stage 1 failure |
| Stage 7 — OWASP ZAP | SKIPPED | Blocked by Stage 1 failure |

> **This is correct and expected behaviour.** A single committed secret is enough to
> block the entire pipeline. The secrets remain in the repository intentionally for
> this engagement — they will be fully remediated in Week 2 Day 6 when HashiCorp
> Vault is deployed and all credentials are rotated and migrated.

---

## REMEDIATION PLAN (Week 2)

| Action | Day | Tool |
|---|---|---|
| Rotate AWS Access Key in IAM console | Day 6 | AWS Console |
| Rotate JWT_SECRET — generate new 256-bit key | Day 6 | HashiCorp Vault |
| Rotate SESSION_SECRET | Day 6 | HashiCorp Vault |
| Rotate all database passwords | Day 6 | HashiCorp Vault |
| Rotate SonarQube token | Day 6 | SonarCloud dashboard |
| Remove all secrets from docker-compose.yml | Day 7 | git |
| Remove .env from tracking | Day 7 | git |
| Rewrite Git history with git-filter-repo | Day 7 | git-filter-repo |
| Migrate all secrets to Vault with per-service policies | Day 6 | HashiCorp Vault |
| Replace Kubernetes ConfigMap secrets with Vault injection | Day 6 | Vault Agent Injector |
| Replace Terraform hardcoded password with Vault reference | Day 7 | Terraform + Vault |
| Verify Gitleaks Stage 1 passes after remediation | Day 7 | GitHub Actions |