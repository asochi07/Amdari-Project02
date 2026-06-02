# Stage 4 — IaC and Kubernetes Scan Results
# SecureFlow DevSecOps Pipeline — Stage 4 Evidence
# Tools: Trivy K8s + Checkov | Date: June 2026

---

## TRIVY KUBERNETES MANIFEST SCAN — 16 HIGH Findings

| # | Finding ID | Severity | File | Description | Vuln ID |
|---|---|---|---|---|---|
| 1 | KSV-0017 | HIGH | base/auth-service.yaml | Privileged container enabled | CK-04 |
| 2 | KSV-0014 | HIGH | base/auth-service.yaml | Root filesystem is not read-only | CK-04 |
| 3 | KSV-0118 | HIGH | base/auth-service.yaml | Default security context configured | CK-04 |
| 4 | KSV-0109 | HIGH | base/configmap.yaml | ConfigMap contains secrets | CK-09 |
| 5 | KSV-0014 | HIGH | base/databases.yaml | Root filesystem not read-only (x2) | CK-04 |
| 6 | KSV-0118 | HIGH | base/databases.yaml | Default security context (x4) | CK-04 |
| 7 | KSV-0017 | HIGH | base/frontend.yaml | Privileged container enabled | CK-04 |
| 8 | KSV-0014 | HIGH | base/frontend.yaml | Root filesystem is not read-only | CK-04 |
| 9 | KSV-0118 | HIGH | base/frontend.yaml | Default security context configured | CK-04 |
| 10 | KSV-0017 | HIGH | base/transaction-service.yaml | Privileged container enabled | CK-04 |
| 11 | KSV-0014 | HIGH | base/transaction-service.yaml | Root filesystem is not read-only | CK-04 |
| 12 | KSV-0118 | HIGH | base/transaction-service.yaml | Default security context configured | CK-04 |

**Gate result: HARD-FAIL — 16 HIGH findings**

### Vulnerability Index Mapping
| KSV ID | Description | Vuln ID | Remediation |
|---|---|---|---|
| KSV-0017 | Privileged container | CK-04 | Set privileged: false Week 2 Day 7 |
| KSV-0014 | Root filesystem writable | CK-04 | Set readOnlyRootFilesystem: true Week 2 Day 7 |
| KSV-0118 | Default security context | CK-04 | Add explicit securityContext Week 2 Day 7 |
| KSV-0109 | Secrets in ConfigMap | CK-09 | Migrate to Vault Week 2 Day 6 |

---

## CHECKOV TERRAFORM IaC SCAN — 72 Failed Checks

### Key Findings Mapped to Vulnerability Index

**IAM Module — IV-08 (Overly Permissive IAM)**

| Checkov ID | Resource | File | Description | Vuln ID |
|---|---|---|---|---|
| CKV_AWS_274 | aws_iam_role_policy_attachment.admin_access | iam/main.tf:23 | IAM policy grants AdministratorAccess | IV-08 |
| CKV_AWS_274 | aws_iam_role_policy_attachment.node_admin | eks/main.tf:65 | EKS node role with AdminAccess | IV-08 |
| CKV_AWS_62 | aws_iam_role_policy.app_inline | iam/main.tf:44 | IAM policy not constrained to resources | IV-08 |
| CKV_AWS_63 | aws_iam_role_policy.app_inline | iam/main.tf:44 | IAM policy allows * actions | IV-08 |
| CKV2_AWS_40 | aws_iam_role_policy.app_inline | iam/main.tf | IAM policy allows privilege escalation | IV-08 |

**S3 Module — IV-09 (Unencrypted/Misconfigured S3)**

| Checkov ID | Resource | File | Description | Vuln ID |
|---|---|---|---|---|
| CKV_AWS_145 | aws_s3_bucket.artifacts | s3/main.tf | S3 bucket not encrypted with KMS | IV-09 |
| CKV_AWS_145 | aws_s3_bucket.audit_logs | s3/main.tf | S3 bucket not encrypted with KMS | IV-09 |
| CKV_AWS_18 | aws_s3_bucket.artifacts | s3/main.tf | S3 access logging disabled | IV-09 |
| CKV_AWS_18 | aws_s3_bucket.audit_logs | s3/main.tf | S3 access logging disabled | IV-09 |
| CKV_AWS_21 | aws_s3_bucket.artifacts | s3/main.tf | S3 versioning disabled | IV-09 |
| CKV_AWS_21 | aws_s3_bucket.audit_logs | s3/main.tf | S3 versioning disabled | IV-09 |
| CKV2_AWS_6 | aws_s3_bucket.artifacts | s3/main.tf | S3 bucket public access not blocked | IV-09 |
| CKV2_AWS_6 | aws_s3_bucket.audit_logs | s3/main.tf | S3 bucket public access not blocked | IV-09 |
| CKV_AWS_53 | aws_s3_bucket_public_access_block | s3/main.tf | S3 block public ACLs disabled | IV-09 |
| CKV_AWS_54 | aws_s3_bucket_public_access_block | s3/main.tf | S3 block public policy disabled | IV-09 |
| CKV_AWS_55 | aws_s3_bucket_public_access_block | s3/main.tf | S3 ignore public ACLs disabled | IV-09 |
| CKV_AWS_56 | aws_s3_bucket_public_access_block | s3/main.tf | S3 restrict public buckets disabled | IV-09 |
| CKV2_AWS_61 | aws_s3_bucket.artifacts | s3/main.tf | S3 MFA delete not enabled | IV-09 |
| CKV2_AWS_62 | aws_s3_bucket.artifacts | s3/main.tf | S3 event notifications not enabled | IV-09 |
| CKV_AWS_144 | aws_s3_bucket.artifacts | s3/main.tf | S3 cross-region replication disabled | IV-09 |

**VPC / Networking Module — IV-10 (Public Subnets / Open Security Groups)**

| Checkov ID | Resource | File | Description | Vuln ID |
|---|---|---|---|---|
| CKV_AWS_130 | aws_subnet.public[0] | vpc/main.tf | EKS/subnet assigns public IP on launch | IV-10 |
| CKV_AWS_130 | aws_subnet.public[1] | vpc/main.tf | EKS/subnet assigns public IP on launch | IV-10 |
| CKV_AWS_23 | aws_security_group.wide_open | vpc/main.tf | Security group allows all ingress | IV-10 |
| CKV_AWS_24 | aws_security_group.wide_open | vpc/main.tf | Security group allows SSH from 0.0.0.0/0 | IV-10 |
| CKV_AWS_25 | aws_security_group.wide_open | vpc/main.tf | Security group allows RDP from 0.0.0.0/0 | IV-10 |
| CKV_AWS_260 | aws_security_group.wide_open | vpc/main.tf | Security group allows unrestricted egress | IV-10 |
| CKV2_AWS_5 | aws_security_group.wide_open | vpc/main.tf | Security group not attached to resource | IV-10 |
| CKV2_AWS_12 | aws_vpc.main | vpc/main.tf | VPC flow logs not enabled | IV-10 |

**EKS Module — IV-10 (EKS Security)**

| Checkov ID | Resource | File | Description | Vuln ID |
|---|---|---|---|---|
| CKV_AWS_339 | aws_eks_cluster.main | eks/main.tf:31 | EKS cluster not private | IV-10 |
| CKV_AWS_38 | aws_eks_cluster.main | eks/main.tf:31 | EKS API server endpoint public access enabled | IV-10 |
| CKV_AWS_37 | aws_eks_cluster.main | eks/main.tf:31 | EKS cluster logging not enabled | IV-10 |
| CKV_AWS_58 | aws_eks_cluster.main | eks/main.tf:31 | EKS cluster secrets not encrypted | IV-10 |
| CKV_AWS_39 | aws_eks_cluster.main | eks/main.tf:31 | EKS cluster has outdated K8s version | IV-10 |

**RDS Module — IV-09 (Unencrypted/Misconfigured Database)**

| Checkov ID | Resource | File | Description | Vuln ID |
|---|---|---|---|---|
| CKV_AWS_16 | aws_db_instance.auth | rds/main.tf:35 | RDS storage encryption disabled | IV-09 |
| CKV_AWS_16 | aws_db_instance.transactions | rds/main.tf:55 | RDS storage encryption disabled | IV-09 |
| CKV_AWS_17 | aws_db_instance.auth | rds/main.tf:35 | RDS not in private subnet | IV-09 |
| CKV_AWS_17 | aws_db_instance.transactions | rds/main.tf:55 | RDS not in private subnet | IV-09 |
| CKV_AWS_118 | aws_db_instance.auth | rds/main.tf:35 | RDS backup retention too short | IV-09 |
| CKV_AWS_118 | aws_db_instance.transactions | rds/main.tf:55 | RDS backup retention too short | IV-09 |
| CKV_AWS_129 | aws_db_instance.auth | rds/main.tf:35 | RDS not using IAM authentication | IV-09 |
| CKV_AWS_157 | aws_db_instance.auth | rds/main.tf:35 | RDS auto minor version upgrade disabled | IV-09 |
| CKV_AWS_161 | aws_db_instance.auth | rds/main.tf:35 | RDS Enhanced Monitoring disabled | IV-09 |
| CKV_AWS_293 | aws_db_instance.auth | rds/main.tf:35 | RDS deletion protection disabled | IV-09 |
| CKV_AWS_226 | aws_db_instance.auth | rds/main.tf:35 | RDS snapshot not encrypted | IV-09 |
| CKV2_AWS_60 | aws_db_instance.auth | rds/main.tf | RDS cluster not using IAM auth | IV-09 |
| CKV2_AWS_30 | aws_db_instance.auth | rds/main.tf | RDS instance not using Secrets Manager | IV-09 |

---

## STAGE 4 GATE RESULTS

| Scanner | Findings | Gate |
|---|---|---|
| Trivy K8s | 16 HIGH | HARD-FAIL |
| Checkov | 72 failed checks | HARD-FAIL |
| **Combined** | **88 findings** | **HARD-FAIL** |

---

## SUMMARY BY VULNERABILITY INDEX

| Vuln ID | Description | Trivy K8s | Checkov | Total | Week 2 Action |
|---|---|---|---|---|---|
| CK-04 | Privileged containers / weak security context | 9 | 0 | 9 | Harden manifests Day 7 |
| CK-09 | Secrets in ConfigMap | 1 | 0 | 1 | Migrate to Vault Day 6 |
| IV-08 | Overly permissive IAM | 0 | 5 | 5 | Least-privilege IAM Day 8 |
| IV-09 | Unencrypted/misconfigured S3 and RDS | 0 | 41 | 41 | Enable encryption Day 8 |
| IV-10 | Public subnets / open security groups | 0 | 14 | 14 | Private subnets Day 8 |
| **TOTAL** | | **10** | **60** | **70** | |

---

## IMPORTANT OBSERVATION

The security group named `wide_open` in vpc/main.tf is particularly
significant. The name itself documents the vulnerability — SSH
(port 22) and RDP (port 3389) are open to 0.0.0.0/0 meaning the
entire internet. This is a textbook example of IV-10 and would be
immediately flagged in any cloud security audit.

The EKS API server endpoint is publicly accessible (CKV_AWS_38)
meaning the Kubernetes control plane can be reached from the internet.
Combined with the weak IAM policies, this represents a critical
attack path: public EKS API + admin IAM role = full cluster takeover.