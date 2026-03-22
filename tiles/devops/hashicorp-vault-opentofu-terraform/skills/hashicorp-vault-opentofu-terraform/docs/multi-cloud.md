# Multi-Cloud Enterprise Patterns Reference

Dynamic credentials and provider configurations for multi-cloud environments.

## 1. Multiple Vault Provider Configurations

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

## 2. AWS Dynamic Credentials

```hcl
# multi-cloud/aws.tf

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

## 3. Azure Dynamic Credentials

```hcl
# multi-cloud/azure.tf

# Configure Azure secrets engine
resource "vault_azure_secret_backend" "main" {
  subscription_id = var.azure_subscription_id
  tenant_id       = var.azure_tenant_id
  client_id       = var.azure_client_id
  client_secret   = var.azure_client_secret
}

# Create role for dynamic credentials
resource "vault_azure_secret_backend_role" "deploy_role" {
  backend           = vault_azure_secret_backend.main.path
  name              = "deploy-role"
  application_id    = var.azure_application_id
  credential_type   = "service_principal"
}

# Read dynamic credentials
data "vault_azure_access_credentials" "deploy" {
  backend = vault_azure_secret_backend.main.path
  role    = vault_azure_secret_backend_role.deploy_role.name
}

# Use with Azure provider
provider "azurerm" {
  client_id     = data.vault_azure_access_credentials.deploy.client_id
  client_secret = data.vault_azure_access_credentials.deploy.client_secret
  tenant_id     = var.azure_tenant_id
  subscription_id = var.azure_subscription_id
}
```

## 4. GCP Dynamic Credentials

```hcl
# multi-cloud/gcp.tf

# Configure GCP secrets engine
resource "vault_gcp_secret_backend" "main" {
  credentials = var.gcp_service_account_key
}

# Create IAM role for dynamic credentials
resource "vault_gcp_secret_backend_role" "deploy_role" {
  backend         = vault_gcp_secret_backend.main.path
  name           = "deploy-role"
  credential_type = "gcp_iam"
  project        = var.gcp_project
  policies = {
    "roles/storage.objectViewer" = ["resource:project:${var.gcp_project}"]
  }
}

# Read dynamic credentials
data "vault_gcp_access_credentials" "deploy" {
  backend = vault_gcp_secret_backend.main.path
  role    = vault_gcp_secret_backend_role.deploy_role.name
}

# Use with GCP provider
provider "google" {
  credentials = data.vault_gcp_access_credentials.deploy.credentials
  project     = var.gcp_project
  region      = "us-central1"
}
```

## 5. Consolidated Multi-Cloud Provider

```hcl
# multi-cloud/providers.tf

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
  alias       = "gcp"
  credentials = data.vault_gcp_access_credentials.gcp_creds.credentials
  project     = var.gcp_project
  region      = "us-central1"
}
```

## Validation Commands

```bash
# Test AWS credentials
aws sts get-caller-identity

# Test Azure credentials
az account show

# Test GCP credentials
gcloud auth list

# Check Vault lease
vault list sys/leases/lookup/aws/creds/
```

## TTL Best Practices

| Cloud | Default TTL | Max TTL | Notes |
|-------|-------------|---------|-------|
| AWS | 1h | 24h | Short TTLs reduce exposure |
| Azure | 1h | 24h | Similar to AWS |
| GCP | 1h | 12h | Shorter max for GCP tokens |
