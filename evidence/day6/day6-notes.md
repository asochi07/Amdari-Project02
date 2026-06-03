# Day 6 Notes — HashiCorp Vault Integration

## 1. What is HashiCorp Vault?
Vault is a secrets management tool that stores, controls access to, and
audits secrets (passwords, API keys, certificates). Instead of secrets
living in plaintext in code, config, or environment variables, they live
encrypted in Vault and are delivered to applications only at runtime,
only to authorised identities.

## 2. Dev Mode vs Production Mode

| Aspect     | Dev Mode                        | Production Mode                                  |
|------------|---------------------------------|--------------------------------------------------|
| Storage    | In-memory only — lost on restart| Persistent backend (Consul, Raft, cloud)         |
| Unseal     | Auto-unsealed, single key       | Manual unseal or auto-unseal (KMS), 5 key shares |
| Root token | Printed to console, well-known  | Generated securely, tightly controlled           |
| TLS        | Disabled (HTTP)                 | Required (HTTPS)                                 |
| Audit      | Not enabled by default          | Mandatory audit devices                          |
| Use case   | Local testing and learning ONLY | Real secret storage                              |

### Why Dev Mode is Acceptable Here
This is a training engagement. Dev mode lets us demonstrate the full
Vault integration pattern — auth methods, policies, injection — without
the operational overhead of unsealing and persistent storage. The
SECURITY PATTERN is identical; only the durability and unseal differ.

### What Production Would Add
- Raft integrated storage for persistence across restarts
- Auto-unseal via AWS KMS so no human holds unseal keys
- Audit logging to a SIEM for compliance (SOC 2, FCA)
- TLS everywhere
- Vault running with anti-affinity across availability zones