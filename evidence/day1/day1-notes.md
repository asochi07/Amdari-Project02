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

## Scope — What I Fix vs What I Route
### I Fix (DevSecOps owned):
- Committed secrets, container CVEs, Kubernetes misconfigs, IaC misconfigs

### I Route to AppSec:
- SQL injection, IDOR, XSS, CSRF, insecure password storage