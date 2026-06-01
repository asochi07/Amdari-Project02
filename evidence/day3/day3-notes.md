## Gitleaks Stage 1 — Hard-Fail Confirmed

Total secrets found: 27
Pipeline exit code: 1 — hard-fail confirmed
All subsequent stages skipped

### Key Findings from .env (commit b99bc4e)
- AWS_ACCESS_KEY_ID — aws-access-token rule
- JWT_SECRET — jwt-secret custom rule
- SESSION_SECRET — flask-secret-key custom rule
- AUTH_DB_PASSWORD — db-password-env custom rule
- TRANSACTION_DB_PASSWORD — db-password-env custom rule
- SONAR_TOKEN — sonarqube-token custom rule

### Key Findings from docker-compose.yml (commit 6726695)
- JWT_SECRET, SESSION_SECRET, DB_PASSWORD x4

### Bonus Findings Discovered
- infra/kubernetes/base/configmap.yaml — secrets in K8s ConfigMap (CK-09)
- infra/terraform/main.tf — hardcoded DB password (IV-01)

### Fix Applied
- Added evidence/ and reports/ to .gitleaks.toml allowlist
  to prevent documentation files from triggering false positives

body: |
  ## Gitleaks Secret Detection Alert

  A Gitleaks scan detected one or more committed secrets in this repository.

  **Immediate Actions Required:**
  1. Download the `gitleaks-report` artifact from the failed workflow run
  2. Identify which secrets were found and in which commits
  3. Rotate ALL exposed credentials immediately in their respective systems
  4. Rewrite Git history using git-filter-repo to remove secrets from all commits
  5. Verify the pipeline passes after remediation

  **Workflow Run:** ${{ github.server_url }}/${{ github.repository }}/actions/runs/${{ github.run_id }}

  **Owner:** DevSecOps Team
  **Severity:** CRITICAL
  **SLA:** Immediate rotation required — do not merge until resolved