# Master Findings Summary Table
# SecureFlow DevSecOps Pipeline — All Stages (Days 3 and 4)
# Generated: June 2026
# Sources: Gitleaks (Stage 1), SonarQube (Stage 2), Trivy (Stage 3), Trivy K8s + Checkov (Stage 4)

---

## PIPELINE GATE OVERVIEW

| Stage | Tool | Hard-Fail Findings | Soft-Fail Findings | Status |
|---|---|---|---|---|
| Stage 1 | Gitleaks | 20 secrets | 0 | HARD-FAIL |
| Stage 2 | SonarQube | 4 (BLOCKER) | 25 (MAJOR/MINOR) | HARD-FAIL |
| Stage 3 | Trivy Image | 15 (CRITICAL/HIGH) | 0 | HARD-FAIL |
| Stage 4 | Trivy K8s | 16 (HIGH) | 0 | HARD-FAIL |
| Stage 4 | Checkov | 72 (failed checks) | 0 | HARD-FAIL |

---

## STAGE 1 — GITLEAKS SECRET DETECTION

| # | Tool     | Finding ID       | Description                                 | Severity | File | Line | Vuln ID | Owner | Gate |
|---|----------|------------------|---------------------------------------------|----------|--------|---|---|---|---|
| 1 | Gitleaks | aws-access-token | AWS_ACCESS_KEY_ID=REDACTED-AWS-KEY          | CRITICAL | .env | 15 | IV-04 | DevSecOps | Hard-fail |
| 2 | Gitleaks | jwt-secret | JWT_SECRET=REDACTED-ROTATED-SECRET | CRITICAL | .env | 35 | AV-07, IV-04 | DevSecOps | Hard-fail |
| 3 | Gitleaks | flask-secret-key | SESSION_SECRET=REDACTED-ROTATED-SECRET | CRITICAL | .env | 40 | FV-03, IV-04 | DevSecOps | Hard-fail |
| 4 | Gitleaks | db-password-env | AUTH_DB_PASSWORD=REDACTED-ROTATED-SECRET | CRITICAL | .env | 20 | IV-01, IV-04 | DevSecOps | Hard-fail |
| 5 | Gitleaks | db-password-env | TRANSACTION_DB_PASSWORD=REDACTED-ROTATED-SECRET | CRITICAL | .env | 26 | IV-01, IV-04 | DevSecOps | Hard-fail |
| 6 | Gitleaks | sonarqube-token | SONAR_TOKEN=REDACTED-example... | HIGH | .env | 44 | IV-04 | DevSecOps | Hard-fail |
| 7 | Gitleaks | jwt-secret | JWT_SECRET: REDACTED-ROTATED-SECRET | CRITICAL | docker-compose.yml | 45 | AV-07, IV-03 | DevSecOps | Hard-fail |
| 8 | Gitleaks | flask-secret-key | SESSION_SECRET: REDACTED-ROTATED-SECRET | CRITICAL | docker-compose.yml | 69 | FV-03, IV-03 | DevSecOps | Hard-fail |
| 9 | Gitleaks | db-password-env | POSTGRES_PASSWORD: REDACTED-ROTATED-SECRET | CRITICAL | docker-compose.yml | 18 | IV-01, IV-03 | DevSecOps | Hard-fail |
| 10 | Gitleaks | db-password-env | POSTGRES_PASSWORD: REDACTED-ROTATED-SECRET | CRITICAL | docker-compose.yml | 30 | IV-01, IV-03 | DevSecOps | Hard-fail |
| 11 | Gitleaks | db-password-env | DB_PASSWORD: REDACTED-ROTATED-SECRET | CRITICAL | docker-compose.yml | 44 | IV-01, IV-03 | DevSecOps | Hard-fail |
| 12 | Gitleaks | db-password-env | DB_PASSWORD: REDACTED-ROTATED-SECRET | CRITICAL | docker-compose.yml | 58 | IV-01, IV-03 | DevSecOps | Hard-fail |
| 13 | Gitleaks | jwt-secret | JWT_SECRET: "REDACTED-ROTATED-SECRET" | CRITICAL | infra/kubernetes/base/configmap.yaml | 9 | AV-07, CK-09 | DevSecOps | Hard-fail |
| 14 | Gitleaks | flask-secret-key | SESSION_SECRET: "REDACTED-ROTATED-SECRET" | CRITICAL | infra/kubernetes/base/configmap.yaml | 10 | FV-03, CK-09 | DevSecOps | Hard-fail |
| 15 | Gitleaks | db-password-env | AUTH_DB_PASSWORD: "REDACTED-ROTATED-SECRET" | CRITICAL | infra/kubernetes/base/configmap.yaml | 11 | IV-01, CK-09 | DevSecOps | Hard-fail |
| 16 | Gitleaks | db-password-env | TX_DB_PASSWORD: "REDACTED-ROTATED-SECRET" | CRITICAL | infra/kubernetes/base/configmap.yaml | 12 | IV-01, CK-09 | DevSecOps | Hard-fail |
| 17 | Gitleaks | hashicorp-tf-password | db_password = "REDACTED-ROTATED-SECRET" | CRITICAL | infra/terraform/main.tf | 66 | IV-01, IV-08 | DevSecOps | Hard-fail |
| 18 | Gitleaks | flask-secret-key | SECRET_KEY = 'REDACTED-ROTATED-SECRET' | MEDIUM | VULNERABILITIES.md | 19 | AV-07 | DevSecOps | Hard-fail |
| 19 | Gitleaks | flask-secret-key | SESSION_SECRET='REDACTED-ROTATED-SECRET' | MEDIUM | VULNERABILITIES.md | 40 | FV-03 | DevSecOps | Hard-fail |
| 20 | Gitleaks | db-password-env | db_password = "REDACTED-ROTATED-SECRET" | CRITICAL | infra/terraform/main.tf | 66 | IV-01 | DevSecOps | Hard-fail |

---

## STAGE 2 — SONARQUBE SAST SCANNING

### BLOCKER Findings (Hard-fail)

| # | Tool | Rule ID | Description | Severity | File | Line | Vuln ID | Owner | Gate |
|---|---|---|---|---|---|---|---|---|---|
| 21 | SonarQube | python:S8392 | App binding to all network interfaces (0.0.0.0) | BLOCKER | services/auth-service/app.py | 162 | IV-02, IV-07 | AppSec | Hard-fail |
| 22 | SonarQube | python:S8392 | App binding to all network interfaces (0.0.0.0) | BLOCKER | services/frontend/app.py | 185 | IV-02, IV-07 | AppSec | Hard-fail |
| 23 | SonarQube | python:S8392 | App binding to all network interfaces (0.0.0.0) | BLOCKER | services/transaction-service/app.py | 201 | IV-02, IV-07 | AppSec | Hard-fail |
| 24 | SonarQube | terraform:S6302 | IAM policy grants all privileges (AdministratorAccess) | BLOCKER | infra/terraform/modules/iam/main.tf | 52 | IV-08 | DevSecOps | Hard-fail |

### MAJOR Findings — DevSecOps Owned (Soft-fail — Remediate Week 2)

| # | Tool | Rule ID | Description | Severity | File | Line | Vuln ID | Owner | Gate |
|---|---|---|---|---|---|---|---|---|---|
| 25 | SonarQube | kubernetes:S6428 | Privileged mode enabled | MAJOR | infra/kubernetes/base/auth-service.yaml | 40 | CK-04 | DevSecOps | Soft-fail |
| 26 | SonarQube | kubernetes:S6430 | Privilege escalation enabled | MAJOR | infra/kubernetes/base/auth-service.yaml | 41 | CK-04 | DevSecOps | Soft-fail |
| 27 | SonarQube | kubernetes:S6596 | Image using :latest tag | MAJOR | infra/kubernetes/base/auth-service.yaml | 20 | CK-06 | DevSecOps | Soft-fail |
| 28 | SonarQube | kubernetes:S6428 | Privileged mode enabled | MAJOR | infra/kubernetes/base/frontend.yaml | 25 | CK-04 | DevSecOps | Soft-fail |
| 29 | SonarQube | kubernetes:S6430 | Privilege escalation enabled | MAJOR | infra/kubernetes/base/frontend.yaml | 26 | CK-04 | DevSecOps | Soft-fail |
| 30 | SonarQube | kubernetes:S6596 | Image using :latest tag | MAJOR | infra/kubernetes/base/frontend.yaml | 18 | CK-06 | DevSecOps | Soft-fail |
| 31 | SonarQube | kubernetes:S6428 | Privileged mode enabled | MAJOR | infra/kubernetes/base/transaction-service.yaml | 37 | CK-04 | DevSecOps | Soft-fail |
| 32 | SonarQube | kubernetes:S6430 | Privilege escalation enabled | MAJOR | infra/kubernetes/base/transaction-service.yaml | 38 | CK-04 | DevSecOps | Soft-fail |
| 33 | SonarQube | kubernetes:S6596 | Image using :latest tag | MAJOR | infra/kubernetes/base/transaction-service.yaml | 18 | CK-06 | DevSecOps | Soft-fail |
| 34 | SonarQube | terraform:S6303 | Unencrypted RDS DB instance | MAJOR | infra/terraform/modules/rds/main.tf | 47 | IV-09 | DevSecOps | Soft-fail |
| 35 | SonarQube | terraform:S6303 | Unencrypted RDS DB instance | MAJOR | infra/terraform/modules/rds/main.tf | 67 | IV-09 | DevSecOps | Soft-fail |
| 36 | SonarQube | terraform:S6364 | RDS backup retention period missing | MAJOR | infra/terraform/modules/rds/main.tf | 35 | IV-09 | DevSecOps | Soft-fail |
| 37 | SonarQube | terraform:S6321 | Overly broad security group ingress | MINOR | infra/terraform/modules/vpc/main.tf | 60 | IV-10 | DevSecOps | Soft-fail |

### MAJOR Findings — AppSec Owned (Soft-fail — Route to AppSec)

| # | Tool | Rule ID | Description | Severity | File | Line | Vuln ID | Owner | Gate |
|---|---|---|---|---|---|---|---|---|---|
| 38 | SonarQube | githubactions:S8264 | Workflow-level read permission not scoped to job | MAJOR | .github/workflows/devsecops-pipeline.yml | 22 | N/A | DevSecOps | Soft-fail |
| 39 | SonarQube | githubactions:S8264 | Workflow-level read permission not scoped to job | MAJOR | .github/workflows/devsecops-pipeline.yml | 23 | N/A | DevSecOps | Soft-fail |
| 40 | SonarQube | githubactions:S8233 | Workflow-level write permission not scoped to job | MAJOR | .github/workflows/devsecops-pipeline.yml | 24 | N/A | DevSecOps | Soft-fail |
| 41 | SonarQube | python:S2068 | Hard-coded password detected | MAJOR | services/auth-service/app.py | 22 | IV-03, AV-07 | DevSecOps + AppSec | Soft-fail |
| 42 | SonarQube | python:S2068 | Hard-coded password detected | MAJOR | services/transaction-service/app.py | 19 | IV-03 | DevSecOps + AppSec | Soft-fail |
| 43 | SonarQube | python:S6965 | HTTP methods not specified on route | MAJOR | services/auth-service/app.py | 35 | AV-04 | AppSec | Soft-fail |
| 44 | SonarQube | python:S6965 | HTTP methods not specified on route | MAJOR | services/transaction-service/app.py | 47 | TV-06 | AppSec | Soft-fail |
| 45 | SonarQube | python:S6965 | HTTP methods not specified on route | MAJOR | services/frontend/app.py | 75 | FV-05 | AppSec | Soft-fail |
| 46 | SonarQube | python:S6965 | HTTP methods not specified on route | MAJOR | services/frontend/app.py | 129 | FV-05 | AppSec | Soft-fail |
| 47 | SonarQube | python:S6965 | HTTP methods not specified on route | MAJOR | services/frontend/app.py | 173 | FV-05 | AppSec | Soft-fail |
| 48 | SonarQube | python:S6965 | HTTP methods not specified on route | MAJOR | services/frontend/app.py | 179 | FV-05 | AppSec | Soft-fail |

---

## STAGE 3 — TRIVY CONTAINER IMAGE SCANNING

All three services (auth-service, frontend, transaction-service) share the same
python:3.9-slim base image and therefore have identical CVE findings.

### CRITICAL CVEs — Hard-Fail (5 per service = 15 total)

| # | Tool | CVE ID | Package | Installed | Fixed | CVSS | Description | Vuln ID | Owner | Gate |
|---|---|---|---|---|---|---|---|---|---|---|
| 49 | Trivy | CVE-2026-31789 | libssl3t64 | 3.5.1-1+deb13u1 | 3.5.5-1~deb13u2 | 9.8 | OpenSSL heap buffer overflow on 32-bit systems | CK-01 | DevSecOps | Hard-fail |
| 50 | Trivy | CVE-2026-31789 | openssl | 3.5.1-1+deb13u1 | 3.5.5-1~deb13u2 | 9.8 | OpenSSL heap buffer overflow on 32-bit systems | CK-01 | DevSecOps | Hard-fail |
| 51 | Trivy | CVE-2026-31789 | openssl-provider-legacy | 3.5.1-1+deb13u1 | 3.5.5-1~deb13u2 | 9.8 | OpenSSL heap buffer overflow on 32-bit systems | CK-01 | DevSecOps | Hard-fail |
| 52 | Trivy | CVE-2026-42496 | perl-base | 5.40.1-6 | No fix available | 9.1 | Archive::Tar symlink extraction vulnerability | CK-01 | DevSecOps | Hard-fail |
| 53 | Trivy | CVE-2026-8376 | perl-base | 5.40.1-6 | No fix available | 9.8 | Perl heap buffer overflow in versions through 5.43.10 | CK-01 | DevSecOps | Hard-fail |

### HIGH CVEs — Hard-Fail (selected key findings)

| # | Tool | CVE ID | Package | Installed | Fixed | CVSS | Description | Vuln ID | Owner | Gate |
|---|---|---|---|---|---|---|---|---|---|---|
| 54 | Trivy | CVE-2026-4878 | libcap2 | 1:2.75-10+b1 | 1:2.75-10+deb13u1 | 7.0 | Privilege escalation via TOCTOU race condition | CK-01 | DevSecOps | Hard-fail |
| 55 | Trivy | CVE-2025-69720 | libncursesw6 | 6.5+20250216-2 | No fix | 7.8 | ncurses buffer overflow — arbitrary code execution | CK-01 | DevSecOps | Hard-fail |
| 56 | Trivy | CVE-2025-15467 | libssl3t64 | 3.5.1-1+deb13u1 | 3.5.4-1~deb13u2 | — | OpenSSL remote code execution via oversize records | CK-01 | DevSecOps | Hard-fail |
| 57 | Trivy | CVE-2025-69421 | libssl3t64 | 3.5.1-1+deb13u1 | 3.5.4-1~deb13u2 | 7.5 | OpenSSL denial of service via malformed PKCS#12 | CK-01 | DevSecOps | Hard-fail |
| 58 | Trivy | CVE-2026-28387 | libssl3t64 | 3.5.1-1+deb13u1 | 3.5.5-1~deb13u2 | 8.1 | OpenSSL arbitrary code execution via use-after-free | CK-01 | DevSecOps | Hard-fail |
| 59 | Trivy | CVE-2026-28388 | libssl3t64 | 3.5.1-1+deb13u1 | 3.5.5-1~deb13u2 | 7.5 | OpenSSL denial of service via NULL pointer dereference | CK-01 | DevSecOps | Hard-fail |
| 60 | Trivy | CVE-2026-28389 | libssl3t64 | 3.5.1-1+deb13u1 | 3.5.5-1~deb13u2 | 7.5 | OpenSSL denial of service in CMS processing | CK-01 | DevSecOps | Hard-fail |
| 61 | Trivy | CVE-2026-28390 | libssl3t64 | 3.5.1-1+deb13u1 | 3.5.5-1~deb13u2 | 7.5 | OpenSSL denial of service via NULL pointer dereference | CK-01 | DevSecOps | Hard-fail |
| 62 | Trivy | CVE-2026-42497 | perl-base | 5.40.1-6 | No fix | 7.5 | Archive::Tar hardlink extraction vulnerability | CK-01 | DevSecOps | Hard-fail |
| 63 | Trivy | CVE-2026-48962 | perl-base | 5.40.1-6 | No fix | — | perl-IO-Compress arbitrary code execution | CK-01 | DevSecOps | Hard-fail |
| 64 | Trivy | CVE-2023-30861 | Flask | 2.2.2 | 2.3.2 / 2.2.5 | 7.5 | Flask permanent session cookie disclosure | CK-01 | DevSecOps | Hard-fail |
| 65 | Trivy | CVE-2026-32597 | PyJWT | 2.4.0 | 2.12.0 | — | PyJWT accepts unknown crit header extensions | CK-01 | DevSecOps | Hard-fail |
| 66 | Trivy | CVE-2026-24049 | wheel | 0.45.1 | 0.46.2 | 5.5 | wheel privilege escalation via malicious file | CK-01 | DevSecOps | Hard-fail |

> Note: auth-service has 31 HIGH CVEs, frontend and transaction-service each have 34 HIGH CVEs.
> All share the same root cause — outdated python:3.9-slim base image.
> Remediation: upgrade to python:3.12-slim (Week 2 Day 7).

---

## STAGE 4 — TRIVY KUBERNETES MANIFEST SCAN

| # | Tool | Finding ID | Description | Severity | File | Vuln ID | Owner | Gate |
|---|---|---|---|---|---|---|---|---|
| 67 | Trivy K8s | KSV-0017 | Privileged container enabled | HIGH | infra/kubernetes/base/auth-service.yaml | CK-04 | DevSecOps | Hard-fail |
| 68 | Trivy K8s | KSV-0014 | Root filesystem not read-only | HIGH | infra/kubernetes/base/auth-service.yaml | CK-04 | DevSecOps | Hard-fail |
| 69 | Trivy K8s | KSV-0118 | Default security context configured | HIGH | infra/kubernetes/base/auth-service.yaml | CK-04 | DevSecOps | Hard-fail |
| 70 | Trivy K8s | KSV-0109 | ConfigMap contains secrets in plaintext | HIGH | infra/kubernetes/base/configmap.yaml | CK-09 | DevSecOps | Hard-fail |
| 71 | Trivy K8s | KSV-0014 | Root filesystem not read-only | HIGH | infra/kubernetes/base/databases.yaml | CK-04 | DevSecOps | Hard-fail |
| 72 | Trivy K8s | KSV-0014 | Root filesystem not read-only | HIGH | infra/kubernetes/base/databases.yaml | CK-04 | DevSecOps | Hard-fail |
| 73 | Trivy K8s | KSV-0118 | Default security context configured (x4) | HIGH | infra/kubernetes/base/databases.yaml | CK-04 | DevSecOps | Hard-fail |
| 74 | Trivy K8s | KSV-0017 | Privileged container enabled | HIGH | infra/kubernetes/base/frontend.yaml | CK-04 | DevSecOps | Hard-fail |
| 75 | Trivy K8s | KSV-0014 | Root filesystem not read-only | HIGH | infra/kubernetes/base/frontend.yaml | CK-04 | DevSecOps | Hard-fail |
| 76 | Trivy K8s | KSV-0118 | Default security context configured | HIGH | infra/kubernetes/base/frontend.yaml | CK-04 | DevSecOps | Hard-fail |
| 77 | Trivy K8s | KSV-0017 | Privileged container enabled | HIGH | infra/kubernetes/base/transaction-service.yaml | CK-04 | DevSecOps | Hard-fail |
| 78 | Trivy K8s | KSV-0014 | Root filesystem not read-only | HIGH | infra/kubernetes/base/transaction-service.yaml | CK-04 | DevSecOps | Hard-fail |
| 79 | Trivy K8s | KSV-0118 | Default security context configured | HIGH | infra/kubernetes/base/transaction-service.yaml | CK-04 | DevSecOps | Hard-fail |

---

## STAGE 4 — CHECKOV TERRAFORM IaC SCAN (Key Findings)

### IAM Module — IV-08

| # | Tool | Checkov ID | Description | File | Resource | Vuln ID | Owner | Gate |
|---|---|---|---|---|---|---|---|---|
| 80 | Checkov | CKV_AWS_274 | IAM role with AdministratorAccess policy | infra/terraform/modules/iam/main.tf | aws_iam_role_policy_attachment.admin_access | IV-08 | DevSecOps | Hard-fail |
| 81 | Checkov | CKV_AWS_274 | EKS node role with AdministratorAccess | infra/terraform/modules/eks/main.tf | aws_iam_role_policy_attachment.node_admin | IV-08 | DevSecOps | Hard-fail |
| 82 | Checkov | CKV_AWS_62 | IAM policy not constrained to specific resources | infra/terraform/modules/iam/main.tf | aws_iam_role_policy.app_inline | IV-08 | DevSecOps | Hard-fail |
| 83 | Checkov | CKV_AWS_63 | IAM policy allows wildcard actions | infra/terraform/modules/iam/main.tf | aws_iam_role_policy.app_inline | IV-08 | DevSecOps | Hard-fail |
| 84 | Checkov | CKV2_AWS_40 | IAM policy allows privilege escalation | infra/terraform/modules/iam/main.tf | aws_iam_role_policy.app_inline | IV-08 | DevSecOps | Hard-fail |

### S3 Module — IV-09

| # | Tool | Checkov ID | Description | File | Resource | Vuln ID | Owner | Gate |
|---|---|---|---|---|---|---|---|---|
| 85 | Checkov | CKV_AWS_145 | S3 bucket not encrypted with KMS | infra/terraform/modules/s3/main.tf | aws_s3_bucket.artifacts | IV-09 | DevSecOps | Hard-fail |
| 86 | Checkov | CKV_AWS_145 | S3 bucket not encrypted with KMS | infra/terraform/modules/s3/main.tf | aws_s3_bucket.audit_logs | IV-09 | DevSecOps | Hard-fail |
| 87 | Checkov | CKV_AWS_18 | S3 access logging disabled | infra/terraform/modules/s3/main.tf | aws_s3_bucket.artifacts | IV-09 | DevSecOps | Hard-fail |
| 88 | Checkov | CKV_AWS_18 | S3 access logging disabled | infra/terraform/modules/s3/main.tf | aws_s3_bucket.audit_logs | IV-09 | DevSecOps | Hard-fail |
| 89 | Checkov | CKV_AWS_21 | S3 versioning disabled | infra/terraform/modules/s3/main.tf | aws_s3_bucket.artifacts | IV-09 | DevSecOps | Hard-fail |
| 90 | Checkov | CKV_AWS_21 | S3 versioning disabled | infra/terraform/modules/s3/main.tf | aws_s3_bucket.audit_logs | IV-09 | DevSecOps | Hard-fail |
| 91 | Checkov | CKV2_AWS_6 | S3 public access not fully blocked | infra/terraform/modules/s3/main.tf | aws_s3_bucket.artifacts | IV-09 | DevSecOps | Hard-fail |
| 92 | Checkov | CKV2_AWS_6 | S3 public access not fully blocked | infra/terraform/modules/s3/main.tf | aws_s3_bucket.audit_logs | IV-09 | DevSecOps | Hard-fail |
| 93 | Checkov | CKV_AWS_53 | S3 block public ACLs disabled | infra/terraform/modules/s3/main.tf | aws_s3_bucket_public_access_block | IV-09 | DevSecOps | Hard-fail |
| 94 | Checkov | CKV_AWS_54 | S3 block public policy disabled | infra/terraform/modules/s3/main.tf | aws_s3_bucket_public_access_block | IV-09 | DevSecOps | Hard-fail |
| 95 | Checkov | CKV_AWS_55 | S3 ignore public ACLs disabled | infra/terraform/modules/s3/main.tf | aws_s3_bucket_public_access_block | IV-09 | DevSecOps | Hard-fail |
| 96 | Checkov | CKV_AWS_56 | S3 restrict public buckets disabled | infra/terraform/modules/s3/main.tf | aws_s3_bucket_public_access_block | IV-09 | DevSecOps | Hard-fail |

### VPC and Security Group Module — IV-10

| # | Tool | Checkov ID | Description | File | Resource | Vuln ID | Owner | Gate |
|---|---|---|---|---|---|---|---|---|
| 97 | Checkov | CKV_AWS_130 | Public subnet assigns public IP on launch | infra/terraform/modules/vpc/main.tf | aws_subnet.public[0] | IV-10 | DevSecOps | Hard-fail |
| 98 | Checkov | CKV_AWS_130 | Public subnet assigns public IP on launch | infra/terraform/modules/vpc/main.tf | aws_subnet.public[1] | IV-10 | DevSecOps | Hard-fail |
| 99 | Checkov | CKV_AWS_23 | Security group allows all ingress | infra/terraform/modules/vpc/main.tf | aws_security_group.wide_open | IV-10 | DevSecOps | Hard-fail |
| 100 | Checkov | CKV_AWS_24 | Security group allows SSH from 0.0.0.0/0 | infra/terraform/modules/vpc/main.tf | aws_security_group.wide_open | IV-10 | DevSecOps | Hard-fail |
| 101 | Checkov | CKV_AWS_25 | Security group allows RDP from 0.0.0.0/0 | infra/terraform/modules/vpc/main.tf | aws_security_group.wide_open | IV-10 | DevSecOps | Hard-fail |
| 102 | Checkov | CKV_AWS_260 | Security group allows unrestricted egress | infra/terraform/modules/vpc/main.tf | aws_security_group.wide_open | IV-10 | DevSecOps | Hard-fail |
| 103 | Checkov | CKV2_AWS_12 | VPC flow logs not enabled | infra/terraform/modules/vpc/main.tf | aws_vpc.main | IV-10 | DevSecOps | Hard-fail |

### EKS Module — IV-10

| # | Tool | Checkov ID | Description | File | Resource | Vuln ID | Owner | Gate |
|---|---|---|---|---|---|---|---|---|
| 104 | Checkov | CKV_AWS_339 | EKS cluster API endpoint not private | infra/terraform/modules/eks/main.tf | aws_eks_cluster.main | IV-10 | DevSecOps | Hard-fail |
| 105 | Checkov | CKV_AWS_38 | EKS API server endpoint publicly accessible | infra/terraform/modules/eks/main.tf | aws_eks_cluster.main | IV-10 | DevSecOps | Hard-fail |
| 106 | Checkov | CKV_AWS_37 | EKS control plane logging not enabled | infra/terraform/modules/eks/main.tf | aws_eks_cluster.main | IV-10 | DevSecOps | Hard-fail |
| 107 | Checkov | CKV_AWS_58 | EKS secrets not encrypted at rest | infra/terraform/modules/eks/main.tf | aws_eks_cluster.main | IV-10 | DevSecOps | Hard-fail |
| 108 | Checkov | CKV_AWS_39 | EKS cluster using outdated Kubernetes version | infra/terraform/modules/eks/main.tf | aws_eks_cluster.main | IV-10 | DevSecOps | Hard-fail |

### RDS Module — IV-09

| # | Tool | Checkov ID | Description | File | Resource | Vuln ID | Owner | Gate |
|---|---|---|---|---|---|---|---|---|
| 109 | Checkov | CKV_AWS_16 | RDS storage encryption disabled | infra/terraform/modules/rds/main.tf | aws_db_instance.auth | IV-09 | DevSecOps | Hard-fail |
| 110 | Checkov | CKV_AWS_16 | RDS storage encryption disabled | infra/terraform/modules/rds/main.tf | aws_db_instance.transactions | IV-09 | DevSecOps | Hard-fail |
| 111 | Checkov | CKV_AWS_17 | RDS instance not in private subnet | infra/terraform/modules/rds/main.tf | aws_db_instance.auth | IV-09 | DevSecOps | Hard-fail |
| 112 | Checkov | CKV_AWS_17 | RDS instance not in private subnet | infra/terraform/modules/rds/main.tf | aws_db_instance.transactions | IV-09 | DevSecOps | Hard-fail |
| 113 | Checkov | CKV_AWS_118 | RDS backup retention period too short | infra/terraform/modules/rds/main.tf | aws_db_instance.auth | IV-09 | DevSecOps | Hard-fail |
| 114 | Checkov | CKV_AWS_118 | RDS backup retention period too short | infra/terraform/modules/rds/main.tf | aws_db_instance.transactions | IV-09 | DevSecOps | Hard-fail |
| 115 | Checkov | CKV_AWS_293 | RDS deletion protection disabled | infra/terraform/modules/rds/main.tf | aws_db_instance.auth | IV-09 | DevSecOps | Hard-fail |
| 116 | Checkov | CKV_AWS_293 | RDS deletion protection disabled | infra/terraform/modules/rds/main.tf | aws_db_instance.transactions | IV-09 | DevSecOps | Hard-fail |
| 117 | Checkov | CKV2_AWS_30 | RDS not using AWS Secrets Manager | infra/terraform/modules/rds/main.tf | aws_db_instance.auth | IV-09 | DevSecOps | Hard-fail |
| 118 | Checkov | CKV2_AWS_30 | RDS not using AWS Secrets Manager | infra/terraform/modules/rds/main.tf | aws_db_instance.transactions | IV-09 | DevSecOps | Hard-fail |

---

## COMPLETE FINDINGS SUMMARY BY VULNERABILITY INDEX

| Vuln ID | Description | Stage 1 | Stage 2 | Stage 3 | Stage 4 | Total | Owner | Week 2 Action |
|---|---|---|---|---|---|---|---|---|
| IV-01 | Hardcoded DB passwords | 8 | 0 | 0 | 0 | 8 | DevSecOps | Vault Day 6 |
| IV-02 | Service bound to all interfaces | 0 | 3 | 0 | 0 | 3 | AppSec | Route |
| IV-03 | Secrets in environment variables | 6 | 2 | 0 | 0 | 8 | DevSecOps | Vault Day 6 |
| IV-04 | Secrets committed in .env | 6 | 0 | 0 | 0 | 6 | DevSecOps | git-filter-repo Day 7 |
| IV-07 | No network segmentation | 0 | 3 | 0 | 0 | 3 | AppSec | Route |
| IV-08 | Overly permissive IAM | 1 | 1 | 0 | 7 | 9 | DevSecOps | Least-privilege IAM Day 8 |
| IV-09 | Unencrypted S3 / RDS | 0 | 4 | 0 | 24 | 28 | DevSecOps | Encryption + private subnets Day 8 |
| IV-10 | Public subnets / open security groups | 0 | 1 | 0 | 13 | 14 | DevSecOps | Private subnets Day 8 |
| AV-04 | No rate limiting / method specs | 0 | 1 | 0 | 0 | 1 | AppSec | Route |
| AV-07 | Hardcoded JWT secret | 4 | 1 | 0 | 0 | 5 | DevSecOps | Vault Day 6 |
| CK-01 | Container CVEs (base image) | 0 | 0 | 15 | 0 | 15 | DevSecOps | Upgrade to python:3.12-slim Day 7 |
| CK-04 | Privileged containers | 0 | 6 | 0 | 9 | 15 | DevSecOps | Harden manifests Day 7 |
| CK-06 | Latest image tag | 0 | 3 | 0 | 0 | 3 | DevSecOps | Pin digests Day 7 |
| CK-09 | Secrets in K8s ConfigMaps | 4 | 0 | 0 | 1 | 5 | DevSecOps | Vault Day 6 |
| FV-03 | Hardcoded session secret | 4 | 0 | 0 | 0 | 4 | DevSecOps | Vault Day 6 |
| FV-05 | CSRF / HTTP method issues | 0 | 4 | 0 | 0 | 4 | AppSec | Route |
| TV-06 | Missing CSRF protection | 0 | 1 | 0 | 0 | 1 | AppSec | Route |

---

## OWNERSHIP BREAKDOWN

| Owner | Total Findings | Action |
|---|---|---|
| DevSecOps — REMEDIATE | 143 | Fix in Week 2 Days 6–8 |
| AppSec — ROUTE | 17 | Surfaced in PR comment — AppSec team fixes |
| **TOTAL** | **160** | |

---

## WEEK 2 REMEDIATION SCHEDULE

| Day | Action | Findings Resolved |
|---|---|---|
| Day 6 | Deploy HashiCorp Vault — migrate all secrets | IV-01, IV-03, IV-04, AV-07, FV-03, CK-09 |
| Day 7 | Harden containers and K8s manifests | CK-01, CK-04, CK-06 |
| Day 8 | Remediate Terraform IaC | IV-08, IV-09, IV-10 |
