# Enterprise Multi-Cloud Vault Setup

## Setup

- Terraform or OpenTofu installed
- Access to HashiCorp Vault (>= 1.15)
- AWS, Azure, and GCP accounts
- Terraform provider `hashicorp/vault` configured

## Task

Set up a production-ready HashiCorp Vault infrastructure as code for a multi-cloud enterprise environment with:

1. **Provider configuration** for production Vault with:
   - TLS certificate verification
   - AppRole authentication (not root token)
   - 1-hour token TTL

2. **Secrets engines** mounted:
   - KV v2 at `secret`
   - AWS dynamic credentials at `aws`
   - PostgreSQL database dynamic credentials at `database`

3. **Authentication methods**:
   - AppRole for CI/CD pipeline
   - Kubernetes auth for production workloads

4. **Policies**:
   - `terraform-admin` policy for Vault management
   - `app-read` policy for application secrets
   - `ci-deploy` policy for CI/CD

5. **Multi-cloud dynamic credentials**:
   - AWS IAM role with EC2 describe permissions
   - PostgreSQL role with SELECT on app schema

6. **Security best practices**:
   - No hardcoded secrets
   - Environment variables for sensitive data
   - Proper resource structure

## Expected Behavior

1. Provider configured with proper auth method (AppRole, not token)
2. All secrets engines mounted correctly
3. Auth methods enabled with appropriate roles
4. Policies created with least-privilege access
5. Dynamic credentials configured for AWS and PostgreSQL
6. Proper directory structure for IaC

## Validation

- [ ] `vault_mount` resources for KV, AWS, Database engines
- [ ] `vault_auth_backend` for AppRole and Kubernetes
- [ ] `vault_approle_auth_backend_role` with proper token TTL
- [ ] `vault_kubernetes_auth_backend_role` with service account binding
- [ ] `vault_policy` resources with proper HCL syntax
- [ ] `vault_aws_secret_backend_role` with IAM policy
- [ ] `vault_database_secret_backend_role` with SQL statements
- [ ] No hardcoded secrets (tokens, passwords)
- [ ] Provider uses `auth_login` block (not `token` argument)
