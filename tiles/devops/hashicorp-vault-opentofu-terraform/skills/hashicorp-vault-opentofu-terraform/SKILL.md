---
name: hashicorp-vault-opentofu-terraform
description: Manage HashiCorp Vault infrastructure as code with Terraform/OpenTofu. Covers provider setup, secrets engines (KV, AWS, Database, PKI), auth methods (AppRole, Kubernetes, JWT/OIDC), policies, dynamic credentials, and Kubernetes integration. Use when user asks to "configure Vault with Terraform", "manage secrets with Vault IaC", "setup Vault auth", "dynamic credentials with Vault", "Vault Kubernetes integration", "Vault policies as code", or mentions Vault + Terraform/OpenTofu together. Triggers on secrets management, credential rotation, certificate management, or secrets injection requests.
---

# HashiCorp Vault OpenTofu/Terraform Skill

Comprehensive guide for managing HashiCorp Vault infrastructure as code using Terraform and OpenTofu.

## When to Use

This skill triggers when:

- User mentions Vault + Terraform/OpenTofu together
- Requests for secrets management, credential rotation, certificate management
- Vault auth method configuration (AppRole, Kubernetes, JWT/OIDC)
- Dynamic secrets setup (AWS, Database, etc.)
- Vault policies as code
- Kubernetes secret injection patterns

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

## Option A: Token authentication (dev/staging)
provider "vault" {
  address = var.vault_address
  token   = var.vault_token  # Set via env VAULT_TOKEN in production
}

## Option B: AppRole for CI/CD
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

## Option C: JWT/OIDC for HCP Terraform
provider "vault" {
  address = var.vault_address
  auth_login_jwt {
    role = "terraform-runner"
    jwt  = var.jwt_token  # From OIDC provider
  }
}

## Option D: AWS IAM for EC2/Lambda
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

### 5. Multi-Cloud Enterprise Patterns

**Step 5.1: Multiple provider configurations**

```hcl
# providers.tf

# Default provider (production Vault)
provider "vault" {
  alias = "prod"
  address = var.prod_vault_address
  token   = var.prod_vault_token
}

# Staging Vault
provider "vault" {
  alias = "staging"
  address = var.staging_vault_address
  token   = var.staging_vault_token
}

# Use with resources
resource "vault_kv_secret_v2" "prod_config" {
  provider = vault.prod
  mount    = "secret"
  name     = "app/config"
  data_json = jsonencode({ env = "production" })
}

resource "vault_kv_secret_v2" "staging_config" {
  provider = vault.staging
  mount    = "secret"
  name     = "app/config"
  data_json = jsonencode({ env = "staging" })
}
```

**Step 5.2: Dynamic credentials for multiple clouds**

```hcl
# multi-cloud/dynamic-creds.tf

# AWS credentials
data "vault_aws_access_credentials" "aws_creds" {
  backend = "aws"
  role    = "deploy-role"
}

provider "aws" {
  alias = "aws"
  access_key = data.vault_aws_access_credentials.aws_creds.access_key
  secret_key = data.vault_aws_access_credentials.aws_creds.secret_key
  token     = data.vault_aws_access_credentials.aws_creds.session_token
  region    = "us-east-1"
}

# Azure credentials
data "vault_azure_access_credentials" "azure_creds" {
  backend = "azure"
  role    = "deploy-role"
}

provider "azurerm" {
  alias = "azure"
  client_id     = data.vault_azure_access_credentials.azure_creds.client_id
  client_secret = data.vault_azure_access_credentials.azure_creds.client_secret
  tenant_id     = var.azure_tenant_id
  subscription_id = var.azure_subscription_id
}

# GCP credentials
data "vault_gcp_access_credentials" "gcp_creds" {
  backend = "gcp"
  role    = "deploy-role"
}

provider "google" {
  alias           = "gcp"
  credentials     = data.vault_gcp_access_credentials.gcp_creds.credentials
  project         = var.gcp_project
  region          = "us-central1"
}
```

### 6. Kubernetes Integration

**Step 6.1: Vault Agent Injector with Helm**

```hcl
# kubernetes/vault-agent.tf

resource "helm_release" "vault_agent" {
  name             = "vault"
  repository       = "https://helm.releases.hashicorp.com"
  chart            = "vault"
  namespace        = "vault"
  create_namespace = true
  version          = "0.27.0"

  values = [
    yamlencode({
      injector = {
        enabled = true
        image = {
          repository = "hashicorp/vault"
          tag        = "1.15"
        }
      }

      server = {
        ha = {
          enabled  = true
          replicas = 3
        }

        dataStorage = {
          size = "10Gi"
        }

        auditStorage = {
          size = "10Gi"
        }
      }
    })
  ]

  set {
    name  = "server.dev.enabled"
    value = "false"
  }

  set {
    name  = "server.standalone.enabled"
    value = "false"
  }
}
```

**Step 6.2: External Secrets Operator integration**

```hcl
# kubernetes/external-secrets.tf

# Install ESO
resource "helm_release" "external_secrets" {
  name             = "external-secrets"
  repository       = "https://charts.external-secrets.io"
  chart            = "external-secrets"
  namespace        = "external-secrets-system"
  create_namespace = true
  version          = "0.9.11"

  set {
    name  = "installCRDs"
    value = "true"
  }
}

# ClusterSecretStore for Vault
resource "kubectl_manifest" "vault_secret_store" {
  yaml_body = <<-YAML
apiVersion: external-secrets.io/v1beta1
kind: ClusterSecretStore
metadata:
  name: vault-backend
spec:
  provider:
    vault:
      server: "https://vault.example.com:8200"
      path: "secret"
      version: "v2"
      auth:
        kubernetes:
          mountPath: "kubernetes"
          role: "eso-role"
  YAML
}

# ExternalSecret to sync Vault secrets
resource "kubectl_manifest" "app_secret" {
  yaml_body = <<-YAML
apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: app-secrets
  namespace: production
spec:
  refreshInterval: 1h
  secretStoreRef:
    name: vault-backend
    kind: ClusterSecretStore
  target:
    name: app-secrets
    creationPolicy: Owner
  data:
    - secretKey: database-url
      remoteRef:
        key: production/app/database
        property: connection_string
    - secretKey: api-key
      remoteRef:
        key: production/app/api
        property: key
  YAML

  depends_on = [
    helm_release.external_secrets,
    kubectl_manifest.vault_secret_store
  ]
}
```

**Step 6.3: Vault Secrets Operator (HashiCorp official)**

```hcl
# kubernetes/vault-secrets-operator.tf

# Install VSO
resource "helm_release" "vso" {
  name             = "vault-secrets-operator"
  repository       = "https://helm.releases.hashicorp.com"
  chart            = "vault-secrets-operator"
  namespace        = "vault-secrets-operator"
  create_namespace = true
  version          = "0.5.0"
}

# VaultConnection
resource "kubectl_manifest" "vault_connection" {
  yaml_body = <<-YAML
apiVersion: secrets.hashicorp.com/v1beta1
kind: VaultConnection
metadata:
  name: vault-connection
  namespace: vault-secrets-operator
spec:
  address: "https://vault.example.com:8200"
  skipTLSVerify: false
  caCertSecretRef:
    name: vault-ca-cert
    namespace: vault-secrets-operator
  YAML
}

# VaultAuth (Kubernetes auth)
resource "kubectl_manifest" "vault_auth" {
  yaml_body = <<-YAML
apiVersion: secrets.hashicorp.com/v1beta1
kind: VaultAuth
metadata:
  name: vault-auth
  namespace: production
spec:
  vaultConnectionRef: vault-connection
  method: kubernetes
  mount: kubernetes
  kubernetes:
    role: app-role
    serviceAccount: app-service-account
  YAML
}

# VaultStaticSecret (sync KV secrets)
resource "kubectl_manifest" "app_config" {
  yaml_body = <<-YAML
apiVersion: secrets.hashicorp.com/v1beta1
kind: VaultStaticSecret
metadata:
  name: app-config
  namespace: production
spec:
  type: kv-v2
  mount: secret
  path: production/app/config
  dest: create
  refreshAfter: 24h
  vaultAuthRef: vault-auth
  metadata:
    name: app-config-secret
  YAML
}
```

### 7. Vault Enterprise Namespaces

**Step 7.1: Multi-tenant namespace structure**

```hcl
# namespaces/multi-tenant.tf

# Create tenant namespaces
resource "vault_namespace" "team_a" {
  path = "team-a"
}

resource "vault_namespace" "team_b" {
  path = "team-b"
}

# Nested namespace
resource "vault_namespace" "team_a_project" {
  namespace = vault_namespace.team_a.path
  path      = "project-x"
}

# Provider for specific namespace
provider "vault" {
  alias    = "team_a"
  address  = var.vault_address
  token    = var.vault_token
  namespace = vault_namespace.team_a.path
}

# Resources in specific namespace
resource "vault_mount" "team_a_kv" {
  provider = vault.team_a
  path     = "secrets"
  type     = "kv"
  options  = { version = "2" }
}

resource "vault_kv_secret_v2" "team_a_secret" {
  provider = vault.team_a
  mount    = vault_mount.team_a_kv.path
  name     = "config"
  data_json = jsonencode({ key = "value" })
}
```

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

## Common Pitfalls

### DON'T:
- Hardcode tokens or secrets in `.tf` files
- Use root tokens in CI/CD
- Grant `*` capabilities in policies
- Store Terraform state locally with secrets
- Skip TLS verification in production

### DO:
- Use environment variables for credentials
- Use AppRole/JWT for machine authentication
- Create specific policies per resource type
- Use remote state with encryption
- Enable and review audit logs

## Troubleshooting

### Error: "permission denied"
- Check Vault policy has required capabilities
- Verify token has `update` on `auth/token/create`
- Check namespace configuration if using Vault Enterprise

### Error: "vault is sealed"
- Unseal Vault with `vault operator unseal`
- Check raft leader status
- Verify storage backend connectivity

### Error: "certificate verify failed"
- Set `VAULT_CACERT` environment variable
- Or set `ca_cert_file` in provider
- For dev: `skip_tls_verify = true` (NOT in production)

### Lease expired errors
- Token TTL too short — increase `max_lease_ttl_seconds`
- Plan ran too long — split into smaller applies
- Use `skip_child_token = false`

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
