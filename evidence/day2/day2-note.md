Key Concepts to Understand and Document
Workflow — A YAML file stored in .github/workflows/ that defines automated tasks. Triggered by events like pushing code or opening a pull request.
Job — A group of steps that run together on the same machine (called a runner). Jobs run in parallel by default unless you define dependencies between them.
Step — A single task within a job. Can be a shell command or a pre-built action.
Action — A reusable, pre-packaged step that someone else has written. For example actions/checkout@v4 downloads your code onto the runner.
Trigger — The event that starts the workflow. Common triggers are push (someone pushes code) and pull_request (someone opens a PR).
Secrets — Encrypted values stored in GitHub repository settings that workflows can use without exposing them in the code. For example your SONAR_TOKEN will be stored here in Day 3.

## Gitleaks Research Notes

### How it detects secrets:
What is Gitleaks?
Gitleaks is an open-source tool that scans Git repositories for accidentally committed secrets — passwords, API keys, tokens, and private keys. It uses two detection methods:
Method 1 — Pattern Matching (Regex)
Gitleaks has built-in rules that match known secret patterns. For example:

AWS Access Keys always start with AKIA followed by 16 uppercase characters
GitHub tokens start with ghp_
SonarQube tokens start with sqp_

Method 2 — Entropy Detection
Entropy is a measure of randomness in a string. Random strings like wJalrXUtnFEMI/K7MDENG have high entropy. Human-readable words have low entropy. Gitleaks flags high-entropy strings that appear in sensitive contexts like variable assignments.

### Key flag:
The Critical Flag — --log-opts='--all'
By default Gitleaks only scans the current working files. The --log-opts='--all' flag tells it to scan the entire Git history including every commit ever made. This is what catches secrets that were committed and later deleted — like the .env file in this project.

### Custom rules file: .gitleaks.toml
Created custom rules for:
- Flask SECRET_KEY and SESSION_SECRET
- JWT_SECRET signing key
- DB_PASSWORD and POSTGRES_PASSWORD
- SONAR_TOKEN

### What Gitleaks will find in this repo:
- .env file committed at b99bc4e containing AWS keys, JWT secret,
  session secret, DB passwords, SonarQube token
- docker-compose.yml hardcoded credentials at 6726695

