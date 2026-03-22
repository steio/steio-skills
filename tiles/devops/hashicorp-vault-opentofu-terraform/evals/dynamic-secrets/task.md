# Dynamic Secrets with Database and Certificate Management

## Setup

- HashiCorp Vault (>= 1.15)
- PostgreSQL database accessible
- Terraform/OpenTofu with providers:
  - `hashicorp/vault`
  - `hashicorp/postgresql` (optional)

## Task

Configure dynamic secrets and certificate management with:

1. **Database Dynamic Credentials**:
   - Mount database secrets engine at `database`
   - Configure PostgreSQL connection with TLS
   - Create role with limited SQL permissions
   - TTL: 1 hour, Max TTL: 24 hours

2. **PKI Certificate Management**:
   - Mount PKI engine at `pki`
   - Configure CA certificate and key
   - Create role for `*.app.example.com` domains
   - TTL: 24 hours

3. **Transit Encryption**:
   - Mount transit engine at `transit`
   - Create AES-256-GCM encryption key
   - Demonstrate encrypt/decrypt data source usage

4. **AWS Dynamic Credentials**:
   - Mount AWS secrets engine at `aws`
   - Configure with IAM credentials
   - Create role for S3 read-only access
   - Dynamic IAM users with policy

5. **Read and Use Dynamic Credentials**:
   - Data sources for database credentials
   - Data sources for AWS credentials
   - Data sources for certificates

## Expected Behavior

1. Database dynamic credentials working with PostgreSQL
2. PKI certificates generated for wildcard domain
3. Transit encryption/decryption functional
4. AWS dynamic IAM credentials for S3
5. All resources properly structured

## Validation

- [ ] `vault_database_secret_backend_connection` for PostgreSQL
- [ ] `vault_database_secret_backend_role` with creation_statements
- [ ] `vault_pki_secret_backend_config_ca` or equivalent
- [ ] `vault_pki_secret_backend_role` for wildcard certs
- [ ] `vault_pki_secret_backend_cert` for certificate generation
- [ ] `vault_transit_secret_backend_key` for encryption
- [ ] `vault_transit_encrypt` data source
- [ ] `vault_aws_secret_backend` configuration
- [ ] `vault_aws_secret_backend_role` with IAM policy
- [ ] `data` sources for reading dynamic credentials
- [ ] Proper TTL settings (1h default, 24h max)
