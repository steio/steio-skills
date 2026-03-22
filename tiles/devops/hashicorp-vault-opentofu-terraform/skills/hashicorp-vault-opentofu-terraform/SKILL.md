---
name: hashicorp-vault-opentofu-terraform
description: Manage HashiCorp Vault infrastructure as code with Terraform/OpenTofu. Covers provider setup, secrets engines (KV, AWS, Database, PKI), auth methods (AppRole, Kubernetes, JWT/OIDC), policies, dynamic credentials, and Kubernetes integration. Use when user asks to "configure Vault with Terraform", "manage secrets with Vault IaC", "setup Vault auth", "dynamic credentials with Vault", "Vault Kubernetes integration", "Vault policies as code", or mentions Vault + Terraform/OpenTofu together. Triggers on secrets management, credential rotation, certificate management, or secrets injection requests.
---

# HashiCorp Vault OpenTofu/Terraform Skill

Comprehensive guide for managing HashiCorp Vault infrastructure as code using Terraform and OpenTofu.

## Core Process

### 1. Provider Configuration

**Step 1.1: Declare provider**

```hcl
# versions.tf
terraform {
  required_version = ">= 1.0"
  required_providers {
    vault = {
      source  = "hashicorp/vault"
      version = "~> 4.0"  # Use 5.x for Vault >= 1.15 with ephemeral resources
    }
  }
}
```

**Step 1.2: Configure provider with authentication**

```hcl
# providers.tf

# Option A: Token authentication (dev/staging)
provider "vault" {
  address = var.vault_address
  token   = var.vault_token  # Set via env VAULT_TOKEN in production
}

# Option B: AppRole for CI/CD
variable "vault_approle_role_id" {}
variable "vault_approle_secret_id" {}

provider "vault" {
  address = var.vault_address
  auth_login {
    path = "auth/approle/login"
    parameters = {
      role_id   = var.vault_approle_role_id
      secret_id = var.vault_approle_secret_id
    }
  }
}

# Option C: JWT/OIDC for HCP Terraform
provider "vault" {
  address = var.vault_address
  auth_login_jwt {
    role = "terraform-runner"
    jwt  = var.jwt_token  # From OIDC provider
  }
}

# Option D: AWS IAM for EC2/Lambda
provider "vault" {
  address = var.vault_address
  auth_login_aws {
    role = "aws-auth-role"
  }
}
```

**Step 1.3: Environment variables (recommended for production)**

```bash
export VAULT_ADDR="https://vault.example.com:8200"
export VAULT_TOKEN="s.xxx"           # Not for CI/CD
export VAULT_CACERT="/path/to/ca.pem" # TLS certificate
export VAULT_NAMESPACE="admin"        # Vault Enterprise namespace
```

**Verify:** Run `vault status` to confirm connection before proceeding.

### 2. Secrets Engines Configuration

**Step 2.1: Mount secrets engines**

```hcl
# secrets-engines/kv-v2.tf

# KV v2 (generic secrets)
resource "vault_mount" "kv_v2" {
  path        = "secret"
  type        = "kv"
  options     = { version = "2" }
  description = "Key-Value secrets engine v2"
}

# AWS dynamic credentials
resource "vault_mount" "aws" {
  path        = "aws"
  type        = "aws"
  description = "AWS dynamic credentials"
}

# Database dynamic credentials
resource "vault_mount" "database" {
  path        = "database"
  type        = "database"
  description = "Database dynamic credentials"
}

# PKI certificates
resource "vault_mount" "pki" {
  path        = "pki"
  type        = "pki"
  description = "PKI certificates"
  config = {
    default_lease_ttl = "168h"
    max_lease_ttl     = "8760h"
  }
}

# Transit encryption
resource "vault_mount" "transit" {
  path        = "transit"
  type        = "transit"
  description = "Encryption as a service"
}
```

**Verify:** Run `vault secrets list` to confirm all engines are mounted.

**Step 2.2: KV v2 secrets**

```hcl
# secrets-engines/kv-v2.tf

# Write static secrets
resource "vault_kv_secret_v2" "app_config" {
  mount = vault_mount.kv_v2.path
  name  = "production/app/config"
  data_json = jsonencode({
    database_url      = "postgres://db.example.com:5432/app"
    api_key           = var.api_key
    encryption_key_id  = "aws-key-1"
  })
}

# Read secrets (data source)
data "vault_kv_secret_v2" "db_creds" {
  mount = vault_mount.kv_v2.path
  name  = "production/database"
}

# Use in resources
resource "aws_db_instance" "main" {
  identifier     = "app-db"
  engine         = "postgres"
  instance_class = "db.t3.micro"

  # Credentials from Vault - marked sensitive automatically
  username = data.vault_kv_secret_v2.db_creds.data["username"]
  password = data.vault_kv_secret_v2.db_creds.data["password"]
}
```

**Verify:** Run `vault kv get secret/production/app/config` to confirm secrets exist.

**Step 2.3: AWS dynamic credentials**

```hcl
# secrets-engines/aws.tf

# Configure AWS secrets engine
resource "vault_aws_secret_backend" "main" {
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  region     = "us-east-1"
}

# Create IAM role for dynamic credentials
resource "vault_aws_secret_backend_role" "deploy_role" {
  backend         = vault_aws_secret_backend.main.path
  name            = "deploy-role"
  credential_type = "iam_user"
  policy_document = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:Describe*",
          "ec2:CreateTags",
          "ec2:RunInstances",
        ]
        Resource = "*"
      }
    ]
  })
}

# Read dynamic credentials
data "vault_aws_access_credentials" "deploy" {
  backend = vault_aws_secret_backend.main.path
  role    = vault_aws_secret_backend_role.deploy_role.name
  type    = "iam_user"
}

# Use with AWS provider
provider "aws" {
  access_key = data.vault_aws_access_credentials.deploy.access_key
  secret_key = data.vault_aws_access_credentials.deploy.secret_key
  token      = data.vault_aws_access_credentials.deploy.session_token
  region     = "us-east-1"
}
```

**Verify:** Run `vault read aws/creds/deploy-role` to test dynamic credentials.

**Step 2.4: Database dynamic credentials**

```hcl
# secrets-engines/database.tf

# Configure PostgreSQL
resource "vault_database_secret_backend_connection" "postgresql" {
  backend       = vault_mount.database.path
  name          = "postgresql"
  plugin_name   = "postgresql-database-plugin"
  connection_url = "postgresql://{{username}}:{{password}}@postgres.example.com:5432/appdb?sslmode=require"

  allowed_roles = ["app-role", "readonly"]

  postgresql {
    username = var.db_admin_user
    password = var.db_admin_password
  }
}

# Create role for dynamic credentials
resource "vault_database_secret_backend_role" "app_role" {
  backend             = vault_mount.database.path
  name                = "app-role"
  db_name             = vault_database_secret_backend_connection.postgresql.name
  creation_statements = [
    "CREATE ROLE \"{{name}}\" WITH LOGIN PASSWORD '{{password}}' VALID UNTIL '{{expiration}}';",
    "GRANT CONNECT ON DATABASE appdb TO \"{{name}}\";",
    "GRANT USAGE ON SCHEMA public TO \"{{name}}\";",
    "GRANT SELECT ON ALL TABLES IN SCHEMA public TO \"{{name}}\";"
  ]
  default_ttl = "1h"
  max_ttl     = "24h"
}

# Read dynamic credentials
data "vault_database_secret_backend_dynamic_credentials" "app" {
  backend = vault_mount.database.path
  role    = vault_database_secret_backend_role.app_role.name
}
```

**Verify:** Run `vault read database/creds/app-role` to test database credentials.

**Step 2.5: PKI certificates**

```hcl
# secrets-engines/pki.tf

# Configure CA
resource "vault_pki_secret_backend_config_ca" "main" {
  backend = vault_mount.pki.path
  certificate = var.ca_certificate
  private_key = var.ca_private_key
}

# Create role for certificates
resource "vault_pki_secret_backend_role" "app" {
  backend            = vault_mount.pki.path
  name               = "app"
  ttl                = "24h"
  allow_localhost    = false
  allowed_domains    = ["example.com", "app.example.com"]
  allow_subdomains   = true
  max_ttl            = "720h"
  generate_lease     = false
}

# Generate certificate
resource "vault_pki_secret_backend_cert" "app" {
  backend     = vault_mount.pki.path
  common_name = "app.example.com"
  ttl         = "24h"
  alt_names   = ["app.example.com"]
  type        = "internal"

  depends_on = [vault_pki_secret_backend_config_ca.main]
}

# Read certificate
output "certificate" {
  value     = vault_pki_secret_backend_cert.app.certificate
  sensitive = true
}

output "private_key" {
  value     = vault_pki_secret_backend_cert.app.private_key
  sensitive = true
}
```

**Verify:** Run `vault read pki/cert` to list certificates.

**Step 2.6: Transit encryption**

```hcl
# secrets-engines/transit.tf

# Create encryption key
resource "vault_transit_secret_backend_key" "app_key" {
  backend = vault_mount.transit.path
  name    = "app-key"
  type    = "aes256-gcm96"
}

# Encrypt data
data "vault_transit_encrypt" "app_data" {
  backend = vault_mount.transit.path
  key     = vault_transit_secret_backend_key.app_key.name
  plaintext = base64encode(jsonencode({ data = "sensitive" }))
}

# Decrypt data
data "vault_transit_decrypt" "app_data" {
  backend = vault_mount.transit.path
  key     = vault_transit_secret_backend_key.app_key.name
  ciphertext = data.vault_transit_encrypt.app_data.ciphertext
}
```

**Verify:** Run `vault transit keys` to list encryption keys.

### 3. Authentication Methods

**Step 3.1: AppRole (machine authentication)**

```hcl
# auth/approle.tf

# Enable AppRole auth method
resource "vault_auth_backend" "approle" {
  type = "approle"
}

# Create AppRole role
resource "vault_approle_auth_backend_role" "terraform" {
  backend   = vault_auth_backend.approle.path
  role_name = "terraform"
  token_ttl = 3600  # 1 hour

  token_policies = [
    "terraform-policy",
    "default",
  ]

  # Bind to secret IDs
  bind_secret_id = true
}

# Get role_id and secret_id (run once to bootstrap)
output "approle_role_id" {
  value = vault_approle_auth_backend_role.terraform.role_id
}

output "approle_secret_id" {
  value     = vault_approle_auth_backend_role.terraform.secret_id
  sensitive = true
}
```

**Verify:** Run `vault read auth/approle/role/terraform` to confirm role exists.

**Test auth:** `vault write auth/approle/login role_id=<role_id> secret_id=<secret_id>`

**Step 3.2: Kubernetes authentication**

```hcl
# auth/kubernetes.tf

# Enable Kubernetes auth
resource "vault_auth_backend" "kubernetes" {
  type = "kubernetes"
}

# Configure Kubernetes auth
resource "vault_kubernetes_auth_backend_config" "main" {
  backend            = vault_auth_backend.kubernetes.path
  kubernetes_host     = "https://kubernetes.default.svc"
  kubernetes_ca_cert = var.k8s_ca_cert
  token_reviewer_jwt = var.k8s_token_reviewer_jwt
}

# Create role for Kubernetes service accounts
resource "vault_kubernetes_auth_backend_role" "app" {
  backend   = vault_auth_backend.kubernetes.path
  role_name = "app"

  bound_service_account_names = ["app-service"]
  bound_service_account_namespaces = ["production"]

  token_policies = ["app-policy"]

  token_ttl     = 3600
  token_max_ttl = 86400
}
```

**Verify:** Run `vault read auth/kubernetes/role/app` to confirm role exists.

**Step 3.3: JWT/OIDC for CI/CD (HCP Terraform)**

```hcl
# auth/jwt-oidc.tf

# Enable JWT auth
resource "vault_auth_backend" "jwt" {
  type = "jwt"
}

# Configure JWT auth with OIDC
resource "vault_jwt_auth_backend" "main" {
  backend        = vault_auth_backend.jwt.path
  oidc_discovery_url = "https://accounts.google.com"
  oidc_client_id      = var.oidc_client_id
  oidc_client_secret  = var.oidc_client_secret
  default_role       = "terraform-runner"
}

# Create role for Terraform runs
resource "vault_jwt_auth_backend_role" "terraform" {
  backend   = vault_auth_backend.jwt.path
  role_name = "terraform-runner"

  bound_audiences = [var.oidc_client_id]
  bound_claims = {
    groups = ["terraform-admins"]
  }

  token_policies = ["terraform-policy"]

  user_claim       = "email"
  groups_claim     = "groups"
  token_ttl        = 3600
  token_max_ttl    = 7200
}
```

**Verify:** Run `vault read auth/jwt/role/terraform-runner` to confirm role exists.

**Step 3.4: AWS IAM authentication**

```hcl
# auth/aws.tf

# Enable AWS auth
resource "vault_auth_backend" "aws" {
  type = "aws"
}

# Configure AWS auth
resource "vault_aws_auth_backend" "main" {
  backend  = vault_auth_backend.aws.path
  client_id      = var.aws_client_id
  client_secret  = var.aws_client_secret
}

# Create role for EC2 instances
resource "vault_aws_auth_backend_role" "ec2_role" {
  backend            = vault_auth_backend.aws.path
  role_name          = "ec2-app-role"
  auth_type          = "ec2"
  bound_ami_id       = "ami-12345678"
  bound_vpc_id       = "vpc-12345678"
  instance_policies = [
    "arn:aws:iam::123456789012:policy/app-policy"
  ]
  token_ttl      = 3600
  token_max_ttl  = 86400
}
```

**Verify:** Run `vault read auth/aws/role/ec2-app-role` to confirm role exists.

### 4. Vault Policies

**Step 4.1: Create policies as code**

```hcl
# policies/terraform-policy.tf

# Policy for Terraform to manage Vault resources
resource "vault_policy" "terraform" {
  name = "terraform-policy"
  policy = <<-EOT
# Allow creating child tokens for Terraform runs
path "auth/token/create" {
  capabilities = ["update"]
}

# Allow reading secrets
path "secret/data/production/*" {
  capabilities = ["read", "list"]
}

# Allow writing secrets (use sparingly)
path "secret/data/terraform/*" {
  capabilities = ["create", "update"]
}

# Allow AWS dynamic credentials
path "aws/creds/*" {
  capabilities = ["read"]
}

# Allow database dynamic credentials
path "database/creds/*" {
  capabilities = ["read"]
}

# Allow managing auth methods
path "sys/auth/*" {
  capabilities = ["read"]
}

# Allow managing policies
path "sys/policies/*" {
  capabilities = ["read", "create", "update"]
}
EOT
}

# Policy for application read access
resource "vault_policy" "app_read" {
  name = "app-read-policy"
  policy = <<-EOT
path "secret/data/production/app/*" {
  capabilities = ["read", "list"]
}

path "secret/metadata/production/app/*" {
  capabilities = ["list"]
}
EOT
}
```

**Verify:** Run `vault policy read terraform-policy` to confirm policy exists.

**Step 4.2: Policy document data source (recommended)**

```hcl
# policies/app-policy.tf

data "vault_policy_document" "app_secrets" {
  rule {
    path         = "secret/data/${var.environment}/app/*"
    capabilities = ["read", "list"]
    description  = "Read application secrets"
  }

  rule {
    path         = "secret/data/${var.environment}/database"
    capabilities = ["read"]
    description  = "Read database credentials"
  }

  rule {
    path         = "aws/creds/${var.environment}-role"
    capabilities = ["read"]
    description  = "Generate AWS credentials"
  }
}

resource "vault_policy" "app_secrets" {
  name   = "${var.environment}-app-policy"
  policy = data.vault_policy_document.app_secrets.hcl
}
```

**Verify:** Run `vault policy list` to see all policies.

### 5. Advanced Topics

Advanced patterns for multi-cloud, Kubernetes, and Enterprise features are documented in separate reference files:

- **Multi-Cloud Patterns**: [@docs/multi-cloud.md](docs/multi-cloud.md)
- **Kubernetes Integration**: [@docs/kubernetes-integration.md](docs/kubernetes-integration.md)
- **Enterprise Namespaces**: [@docs/namespaces.md](docs/namespaces.md)

## Security Best Practices

1. **Never hardcode secrets in Terraform files**
   - Use environment variables
   - Use Vault to store sensitive values
   - Use `.tfvars` files excluded from version control

2. **Protect Terraform state**
   - Use remote backend (S3 with encryption, GCS, etc.)
   - Enable state encryption
   - Restrict access with IAM policies

3. **Use least privilege**
   - Create specific policies for each use case
   - Avoid root tokens in production
   - Grant minimum capabilities

4. **Token management**
   - Use short TTLs (20 min default is good)
   - Use child tokens with limited capabilities
   - Rotate tokens regularly

5. **Audit logging**
   - Enable Vault audit logging
   - Store logs securely
   - Monitor for anomalies

6. **TLS everywhere**
   - Use TLS for Vault communication
   - Verify certificates
   - Rotate CA certificates

## Troubleshooting

### Error: "permission denied"

| Check | Command | Fix |
|-------|---------|-----|
| Policy exists | `vault policy list` | Apply policy with `vault policy write` |
| Token has policy | `vault token lookup` | Check `policies` in output |
| Token can create children | `vault read sys/auth/token/create` | Policy needs `update` capability |
| Namespace (Enterprise) | `vault token lookup` | Check `namespace_path` field |

**If still failing:** Verify policy path matches resource path exactly. Path `secret/data/*` does NOT grant access to `secret/*`.

### Error: "vault is sealed"

1. Check seal status: `vault status`
2. If sealed, unseal: `vault operator unseal <unseal_key>`
3. Check raft status: `vault operator raft peer list`
4. Verify storage connectivity

**If leader election failed:** Wait for Raft to elect new leader or check storage backend logs.

### Error: "certificate verify failed"

| Check | Fix |
|-------|-----|
| CA cert path | Set `VAULT_CACERT` env var |
| Provider config | Add `ca_cert_file = "/path/to/ca.pem"` |
| Dev environment | Set `skip_tls_verify = true` (NOT in production) |

**If using self-signed certs:** Import root CA into system trust store or mount it explicitly.

### Error: "lease expired" or "token not found"

| Cause | Solution |
|-------|----------|
| Token TTL too short | Increase `max_lease_ttl_seconds` in provider |
| Plan ran too long | Split into smaller `terraform apply` runs |
| Token expired between plan/apply | Ensure plan and apply run within token TTL |

**If using child tokens:** Verify parent token has `update` on `auth/token/create`.

### Error: "resource not found" after apply

| Check | Fix |
|-------|-----|
| Resource ID correct | Check resource address in state: `terraform state list` |
| Wrong provider/namespace | Add `provider` or `namespace` attribute |
| Import needed | Run `terraform import <address> <id>` |

**If Vault not responding:** Check Vault is running: `vault status` and verify network connectivity.

## Reference

### Provider Environment Variables

| Variable | Description |
|----------|-------------|
| `VAULT_ADDR` | Vault server address |
| `VAULT_TOKEN` | Authentication token |
| `VAULT_CACERT` | CA certificate file |
| `VAULT_CAPATH` | CA certificate directory |
| `VAULT_SKIP_VERIFY` | Skip TLS verification |
| `VAULT_NAMESPACE` | Vault Enterprise namespace |

### Key Resources Summary

| Resource | Purpose |
|----------|---------|
| `vault_mount` | Mount secrets/auth engines |
| `vault_kv_secret_v2` | KV v2 secrets read/write |
| `vault_aws_secret_backend` | AWS dynamic credentials |
| `vault_database_secret_backend` | Database dynamic credentials |
| `vault_pki_secret_backend` | Certificate management |
| `vault_transit_secret_backend` | Encryption as a service |
| `vault_auth_backend` | Enable auth methods |
| `vault_approle_auth_backend_role` | AppRole roles |
| `vault_kubernetes_auth_backend_role` | Kubernetes auth roles |
| `vault_jwt_auth_backend_role` | JWT/OIDC roles |
| `vault_policy` | Vault policies |
| `vault_namespace` | Enterprise namespaces |

### External Resources

- [Vault Provider Documentation](https://registry.terraform.io/providers/hashicorp/vault/latest)
- [OpenTofu Vault Provider](https://search.opentofu.org/provider/hashicorp/vault)
- [Vault Best Practices](https://developer.hashicorp.com/vault/docs/platform/aws)
- [Vault Security](https://developer.hashicorp.com/vault/docs/internals/security)
