# Vault Enterprise Namespaces Reference

Multi-tenant namespace patterns for Vault Enterprise.

## 1. Basic Namespace Structure

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
```

## 2. Namespaced Providers

```hcl
# namespaces/providers.tf

# Provider for specific namespace
provider "vault" {
  alias     = "team_a"
  address   = var.vault_address
  token     = var.vault_token
  namespace = vault_namespace.team_a.path
}

provider "vault" {
  alias     = "team_b"
  address   = var.vault_address
  token     = var.vault_token
  namespace = vault_namespace.team_b.path
}
```

## 3. Resources in Namespaces

```hcl
# namespaces/team-a-resources.tf

# KV mount in team-a namespace
resource "vault_mount" "team_a_kv" {
  provider = vault.team_a
  path     = "secrets"
  type     = "kv"
  options  = { version = "2" }
}

# Secret in team-a namespace
resource "vault_kv_secret_v2" "team_a_secret" {
  provider = vault.team_a
  mount    = vault_mount.team_a_kv.path
  name     = "config"
  data_json = jsonencode({ key = "value" })
}

# Policy in team-a namespace
resource "vault_policy" "team_a_policy" {
  provider = vault.team_a
  name     = "team-a-policy"
  policy   = <<-EOT
path "team-a/secrets/*" {
  capabilities = ["read", "list"]
}
EOT
}
```

## 4. Dynamic Credentials in Namespaces

```hcl
# namespaces/team-a-database.tf

# Database connection in team-a namespace
resource "vault_database_secret_backend_connection" "team_a_postgres" {
  provider       = vault.team_a
  backend        = "database"
  name          = "postgresql"
  plugin_name   = "postgresql-database-plugin"
  connection_url = "postgresql://{{username}}:{{password}}@db.example.com:5432/team_a?sslmode=require"

  postgresql {
    username = var.db_admin_user
    password = var.db_admin_password
  }
}

# Role in team-a namespace
resource "vault_database_secret_backend_role" "team_a_role" {
  provider             = vault.team_a
  backend             = "database"
  name                = "app-role"
  db_name             = vault_database_secret_backend_connection.team_a_postgres.name
  creation_statements = [
    "CREATE ROLE \"{{name}}\" WITH LOGIN PASSWORD '{{password}}' VALID UNTIL '{{expiration}}';",
    "GRANT CONNECT ON DATABASE team_a TO \"{{name}}\";",
    "GRANT USAGE ON SCHEMA public TO \"{{name}}\";"
  ]
  default_ttl = "1h"
  max_ttl     = "24h"
}
```

## 5. Namespace Hierarchy

```
/
├── team-a/
│   ├── secrets/
│   │   ├── project-x/
│   │   └── project-y/
│   ├── database/
│   │   └── creds/
│   └── policies/
│       ├── team-a-policy
│       └── project-x-policy
├── team-b/
│   ├── secrets/
│   └── policies/
└── shared/
    └── common-secrets/
```

## Validation Commands

```bash
# List top-level namespaces
vault namespace list

# List nested namespaces
vault namespace list -namespace=team-a

# List secrets in namespace
vault list team-a/secrets/metadata

# Check namespace policies
vault policy list -namespace=team-a

# Verify database role
vault read team-a/database/roles/app-role
```

## Best Practices

1. **Isolate by team** - Each team gets own namespace
2. **Nested for projects** - Projects within teams use nested namespaces
3. **Separate auth methods** - Each namespace can have own auth methods
4. **Audit at root** - Enable audit logging at root to capture all
5. **Limit admins** - Use root namespace only for namespace management

## Common Issues

| Issue | Cause | Fix |
|-------|-------|-----|
| Resource not found | Wrong namespace | Set `namespace` attribute on provider |
| Permission denied | Token scope | Token must have capabilities in target namespace |
| Nested path error | Wrong hierarchy | Path must include parent: `parent/child/path` |
