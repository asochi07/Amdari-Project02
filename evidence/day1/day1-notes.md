# Day 1 Notes — Environment Setup

## Services Running
- frontend: ✅ port 5000
- auth-service: ✅ port 5001
- transaction-service: ✅ port 5002
- auth-db: ✅ port 5432
- transaction-db: ✅ port 5433

## Hardcoded Credentials Found

| Variable          | Value                 | Service             | Vuln ID           | Risk              |
|-------------------|-----------------------|---------------------|-------------------|-------------------|
| POSTGRES_PASSWORD | REDACTED-ROTATED-SECRET           | auth-db             | IV-01, IV-03      | DB access         |
| POSTGRES_PASSWORD | REDACTED-ROTATED-SECRET             | transaction-db      | IV-01, IV-03      | DB access         |
| DB_PASSWORD       | REDACTED-ROTATED-SECRET           | auth-service        | IV-01, IV-03      | DB access         |
| JWT_SECRET        | REDACTED-ROTATED-SECRET  | auth-service        | AV-07, IV-03      | Token forgery     |
| DB_PASSWORD       | REDACTED-ROTATED-SECRET             | transaction-service | IV-01, IV-03      | DB access         |
| SESSION_SECRET    | REDACTED-ROTATED-SECRET              | frontend            | FV-03, IV-03      | Session hijack    |


| SESSION_SECRET    | REDACTED-examplesonarqubetoken1234567890abcdef| Code base            | FV-03, IV-03      | Session hijack    |

## Other docker-compose.yml Issues

| Issue                      | Vuln ID     | Impact                               |
|----------------------------|-------------|--------------------------------------|
| postgres:14 no digest pin  | CK-03       | Image swap attack possible           |
| DB ports exposed on host   | IV-02       | Database directly internet-reachable |
| No resource limits         | IV-06       | System crash from resource exhaustion|
| No network segmentation    | IV-07       | All services freely communicate      |


| Secret                 | What It Is                              | Attack Risk
|------------------------|-----------------------------------------|--------------------------    
| AWS_ACCESS_KEY_ID      | Key to access Amazon cloud account      | Attacker can spin up servers, access 
|                        |                                         |S3 buckets, run up huge bills
| AWS_SECRET_ACCESS_KEYT | Pairs with above to authenticate to AWS | Same as above — useless without 
|                        |                                         | both,  dangerous together
| SONAR_TOKEN            | Access token for SonarQube code scanner | Attacker can read code scan results    
|                        |                                         | or disable scanning
| DB_PASSWORD            | Password to the database                | Direct access to all customer data
| JWT secret             | Used to sign login tokens               | Attacker can forge tokens and log in 
                                                                   |as any user


## OWASP Top 10 Mapping

| OWASP Top 10 Item                 | SecureFlow Example
|-----------------------------------|--------------------------------------------------
| A01 — Broken Access Control       | IDOR in transaction-service (TV-01, TV-02) — any user can see any 
|                                   | account
| A02 — Cryptographic Failures      | Passwords stored with MD5 (AV-05), secrets in plaintext .env (IV-04) 
| A03 — Injection                   | SQL injection in login and register endpoints (AV-01, AV-02) 
| A04 — Insecure Design             | No rate limiting on login (AV-04), no ownership checks 
| A05 — Security Misconfiguration   | Containers running as root (IV-05), admin panel unprotected 
|                                   | (AV-06)
| A06 — Vulnerable Components       | python:3.9-slim base image with 47 critical CVEs (CK-01) 
| A07 — Auth and Identity Failures  | Hardcoded JWT secret (AV-07), expired tokens accepted 
|                                   | (TV-07)
| A08 — Software and Data Integrity | No image signing, no SBOM, unpinned image tags (CK-03) 
| A09 — Security Logging Failures   | No runtime monitoring, no centralised logging
| A10 — Server-Side Request Forgery | Not directly present, but missing security headers enable related 
                                    | attacks (FV-07)

## SAST vs DAST vs SCA Notes

|----------------------------------------------
|SAST — Static Application Security Testing
|----------------------------------------------
|Analyses the source code without running the application
|Like a spell-checker reading your code before it executes
|Tool used in this project: SonarQube
|Finds: SQL injection patterns, hardcoded secrets in code, insecure functions
|Runs: at the pipeline stage, before the app is built
|
|-----------------------------------------------------------------------------------
|DAST — Dynamic Application Security Testing
|---------------------------------------------
|Tests the running application by sending real HTTP requests
|Like actually trying to break into the house after it's been built
|Tool used in this project: OWASP ZAP
|Finds: XSS, CSRF, authentication bypasses that only appear at runtime
|Runs: after deployment to a staging environment
|
|----------------------------------------------------------------------------------
|SCA — Software Composition Analysis
|-----------------------------------------
|Scans the third-party libraries and dependencies your code uses
|Like checking every ingredient in a recipe against a list of known dangerous ones
|Tool used in this project: Trivy (also handles this alongside CVE scanning)
|Finds: known vulnerabilities (CVEs) in imported packages
|Runs: during the image scanning stage of the pipeline


## JWT Research Notes
What is JWT? JSON Web Token — a small digital pass that proves who you are after logging in. When you log in, the server creates a token, signs it with a secret key, and gives it to your browser. Every request you make includes that token. The server checks the signature to confirm the token is genuine.

How the SECRET_KEY protects it: The signature is created using the SECRET_KEY. Without the key, you can't create a valid signature.

What happens when it leaks: If an attacker knows the SECRET_KEY, they can create their own token saying they are admin or any other user, sign it with the stolen key, and the server will accept it as completely genuine. This is exactly vulnerability AV-03 and AV-07 in SecureFlow — the key REDACTED-ROTATED-SECRET is hardcoded in the repository.

## Scope — What I Remediate vs What I Route

As a DevSecOps engineer on this engagement, my responsibilities are divided
into two clear categories. I fix what I own. I detect, document, and route
what belongs to the Application Security (AppSec) team.

### What I Will REMEDIATE (DevSecOps Owned)

These are findings in the secrets, container, Kubernetes, and infrastructure
layers. I am responsible for detecting AND fixing these.

| Vulnerability ID| Description                          | Tool That Detects It| MyAction                  |
|-----------------|--------------------------------------|---------------------|---------------------------|
| IV-03           |Secrets in environment variables      | Gitleaks            |Remove, rotate, migrate to
                                                                               | Vault                     |
| IV-04           | Secrets committed in .env file       | Gitleaks            | Remove from code, rewrite
                                                                               | Git history               |
| IV-01           | Hardcoded DB passwords               | Gitleaks            | Migrate to 
                                                                               | Vault                     |
| AV-07           | Hardcoded JWT secret                 | Gitleaks            | Rotate and migrate to
                                                                               | Vault                     |
| FV-03           | Hardcoded session secret             | Gitleaks            | Rotate and migrate to 
                                                                               | Vault                     |
| CK-01           | python:3.9-slim has 47 critical CVEs | Trivy               | Upgrade base image to
                                                                               | python:3.12-slim          |
| CK-02           | Containers running as root           | Trivy / Checkov     | Add USER directive to all
                                                                               | Dockerfiles               |
| CK-03           | Unpinned image tags (:latest)        | Trivy               | Pin all images to specific
                                                                               | SHA digests               |
| CK-04           | Privileged containers in K8s manifests| Trivy K8s   | Set privileged: false on all 
                                                                        |deployments 
| CK-05           | No resource limits in K8s             | Trivy K8s    | Add CPU and memory limits to all|
                                                                         | containers                      |
| CK-06           | :latest image tag in K8s manifests    |OPA Gatekeeper| Replace with digest-pinned
                                                                         | references                      |
| CK-07           | Missing required labels               |OPA Gatekeeper| Add app and team labels to all
                                                                         | resources                       |
| CK-08           | No NetworkPolicy — default allow all  | Trivy K8s    | Implement default-deny
                                                                         | NetworkPolicy                   |
| CK-09           | Secrets stored in Kubernetes ConfigMaps| Trivy K8s   | Migrate to HashiCorp Vault      |
| IV-02           | Databases exposed on host network      | Checkov     | Remove host port bindings       |
| IV-05           | Containers running as root             | Checkov     | Add USER directive to
                                                                         | Dockerfiles                     |
| IV-06           | No resource limits in docker-compose   | Checkov     | Add deploy.resources.limits     |
| IV-07           | No network segmentation                | Checkov     | Define isolated Docker networks |
| IV-08           | IAM roles with AdministratorAccess     | Checkov     | Scope to least-privilege
                                                                         | policies                        |
| IV-09           | Unencrypted S3 buckets                 | Checkov     | Enable AES-256 server-si
                                                                         | encryption                      |
| IV-10           | EKS nodes in public subnets            | Checkov     | Move to private subnets with NAT
                                                                         | Gateway                         |

### What I Will ROUTE to AppSec (Application Security Team Owned)

These are findings in the application code layer. I am responsible for
DETECTING and REPORTING these, but NOT fixing them. The AppSec team owns
the remediation.

| Vulnerability ID| Description                    | Tool That Detects It | My Action                   |
|-------|------------------------------------------|----------------------|-----------------------------|
| AV-01 | SQL injection in /login endpoint         | SonarQube (SAST) | Report in PR comment, tag AppSec team |
| AV-02 | SQL injection in /register endpoint      | SonarQube (SAST) | Report in PR comment, tag AppSec team |
| AV-03 | Broken authentication — JWT manipulation | SonarQube (SAST) | Report in PR comment, tag AppSec team |
| AV-04 | No rate limiting on /login               | SonarQube (SAST) | Report in PR comment, tag AppSec team |
| AV-05 | Passwords stored with MD5 no salt        | SonarQube (SAST) | Report in PR comment, tag AppSec team |
| AV-06 | Admin panel — no authorisation check     | SonarQube (SAST) | Report in PR comment, tag AppSec team |
| AV-08 | Sensitive data in error responses        | SonarQube (SAST) | Report in PR comment, tag AppSec team |
| TV-01 | IDOR — account balance endpoint          | SonarQube / ZAP | Report in PR comment, tag AppSec team |
| TV-02 | IDOR — transaction history endpoint      | SonarQube / ZAP | Report in PR comment, tag AppSec team |
| TV-03 | Negative transfer amount accepted        | SonarQube (SAST) | Report in PR comment, tag AppSec team |
| TV-04 | Mass assignment on virtual card          | SonarQube (SAST) | Report in PR comment, tag AppSec team |
| TV-05 | Balance overflow — no maximum check      | SonarQube (SAST) | Report in PR comment, tag AppSec team |
| TV-06 | Missing CSRF protection                  | OWASP ZAP (DAST) | Report in PR comment, tag AppSec team |
| TV-07 | Expired JWT tokens accepted              | SonarQube (SAST) | Report in PR comment, tag AppSec team |
| FV-01 | Reflected XSS in frontend                | OWASP ZAP (DAST) | Report in PR comment, tag AppSec team |
| FV-02 | Stored XSS in transaction notes          | OWASP ZAP (DAST) | Report in PR comment, tag AppSec team |
| FV-05 | CSRF on transfer form                    | OWASP ZAP (DAST) | Report in PR comment, tag AppSec team |
| FV-06 | Clickjacking — no X-Frame-Options        | OWASP ZAP (DAST) | Report in PR comment, tag AppSec team |
| FV-07 | Missing security headers                 | OWASP ZAP (DAST) | Report in PR comment, tag AppSec team |

### Why This Division Exists

A DevSecOps engineer is not an application developer. In a real organisation,
fixing SQL injection requires understanding the application business logic,
rewriting Flask routes, and testing that the fix does not break functionality.
That work belongs to the team that owns the code.

My role is to ensure that:
1. Every finding is automatically detected on every pull request
2. Every finding is correctly attributed to the right owner
3. DevSecOps-owned findings block the merge (hard-fail)
4. AppSec-owned findings are surfaced and routed without blocking delivery (soft-fail)
5. No finding is ever silently ignored

The pipeline I build this week enforces these ownership boundaries
automatically on every code change.