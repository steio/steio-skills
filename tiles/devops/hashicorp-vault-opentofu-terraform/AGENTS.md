# HashiCorp Vault OpenTofu/Terraform Skill

Manages HashiCorp Vault infrastructure as code using Terraform and OpenTofu providers.

## Provider Versions

| Provider | Version | Terraform | OpenTofu |
|----------|---------|-----------|----------|
| hashicorp/vault | 5.x (latest) | >= 1.11.x | >= 1.6.0 |
| hashicorp/vault | 4.x (stable) | >= 1.0 | >= 1.6.0 |

**Note:** Provider 5.x requires Vault server >= 1.15.x and supports Ephemeral Resources.

## Key Resources

### Secrets Engines
- `vault_mount` — Mount secrets engines (KV, AWS, Database, PKI, Transit, etc.)
- `vault_kv_secret_v2` — Read/write KV v2 secrets
- `vault_aws_secret_backend` — AWS dynamic credentials
- `vault_database_secret_backend_connection` — Database dynamic credentials
- `vault_pki_secret_backend_cert` — Certificate management
- `vault_transit_secret_backend_key` — Encryption as a service

### Auth Methods
- `vault_auth_backend` — Enable auth methods
- `vault_approle_auth_backend_role` — AppRole roles
- `vault_aws_auth_backend_role` — AWS IAM auth
- `vault_kubernetes_auth_backend_config` — Kubernetes auth
- `vault_jwt_auth_backend_role` — JWT/OIDC auth for CI/CD

### Policies & Access
- `vault_policy` — Manage Vault policies
- `vault_namespace` — Vault Enterprise namespaces

## Directory Structure

```
.
├── providers.tf          # Provider configuration
├── auth/                  # Auth method configurations
│   ├── approle.tf
│   ├── kubernetes.tf
│   └── jwt-oidc.tf
├── secrets-engines/       # Secrets engine mounts
│   ├── kv-v2.tf
│   ├── aws.tf
│   ├── database.tf
│   └── pki.tf
├── policies/              # Vault policies
│   └── *.hcl
└── namespaces/             # Multi-tenant namespaces
    └── *.tf
```

## Security Considerations

1. **Never hardcode secrets** — Use env vars or Vault for provider auth
2. **State file protection** — Terraform state contains secrets; encrypt and restrict access
3. **Least privilege** — Grant minimum capabilities needed
4. **Token TTL** — Use short-lived tokens (20 min default)
5. **Audit logs** — Enable Vault audit logging
6. **TLS** — Always use TLS in production

## Quick Reference

```bash
# Environment variables for provider
export VAULT_ADDR="https://vault.example.com:8200"
export VAULT_TOKEN="s.xxx"  # Or use auth_login instead

# Initialize
tofu init  # or terraform init

# Plan/Apply
tofu plan -out=tfplan
tofu apply tfplan
```
