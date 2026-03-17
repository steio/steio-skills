# Tailscale Terraform Provider Reference

## Provider Configuration

### Authentication Methods

| Method | Use Case | Configuration |
|--------|----------|---------------|
| API Key | Development, scripts | `api_key = "tskey-api-..."` |
| OAuth Client | CI/CD, production | `oauth_client_id` + `oauth_client_secret` |
| Environment | Security best practice | `TAILSCALE_API_KEY` env var |

### Provider Schema

```hcl
provider "tailscale" {
  api_key             = string     # API key for authentication
  oauth_client_id     = string     # OAuth client ID
  oauth_client_secret = string     # OAuth client secret
  base_url            = string     # Custom API endpoint (default: https://api.tailscale.com)
  user_agent          = string     # Custom user agent
}
```

## Resources

### tailscale_acl

Manages the tailnet policy file (ACLs, grants, tagOwners, tests).

```hcl
resource "tailscale_acl" "main" {
  acl = string  # JSON or HuJSON policy

  overwrite_existing_content = bool  # Skip import requirement (dangerous!)
  reset_acl_on_destroy       = bool  # Reset to default on destroy
}
```

### tailscale_tailnet_key

Creates pre-authentication keys for node registration.

```hcl
resource "tailscale_tailnet_key" "key" {
  reusable          = bool     # Single-use or reusable
  ephemeral         = bool     # Ephemeral nodes
  preauthorized     = bool     # Auto-approve devices
  expiry            = number   # Seconds until expiry (default: 7776000 = 90 days)
  description       = string   # Key description
  tags              = set(string)  # Tags for authenticated nodes
  recreate_if_invalid = string # 'always' or 'never'
  user_id           = string   # Creator user ID (read-only for OAuth)
}
```

### tailscale_tailnet_settings

Configures tailnet-wide settings.

```hcl
resource "tailscale_tailnet_settings" "settings" {
  acls_externally_managed_on            = bool
  acls_external_link                    = string
  devices_approval_on                   = bool
  devices_auto_updates_on               = bool
  devices_key_duration_days             = number
  users_approval_on                     = bool
  users_role_allowed_to_join_external_tailnet = string
  posture_identity_collection_on        = bool
  https_enabled                         = bool
  network_flow_logging_on               = bool
  regional_routing_on                   = bool
}
```

### tailscale_device_subnet_routes

Enables subnet routes and exit node functionality.

```hcl
resource "tailscale_device_subnet_routes" "routes" {
  device_id = string       # Use node_id from data source
  routes    = set(string)  # CIDR blocks to route
}
```

### tailscale_device_tags

Applies ACL tags to devices.

```hcl
resource "tailscale_device_tags" "tags" {
  device_id = string        # Use node_id from data source
  tags      = set(string)   # Tags with "tag:" prefix
}
```

### tailscale_device_authorization

Approves or rejects devices.

```hcl
resource "tailscale_device_authorization" "auth" {
  device_id  = string
  authorized = bool
}
```

### tailscale_device_key

Manages device key settings.

```hcl
resource "tailscale_device_key" "key" {
  device_id               = string
  key_expiry_disabled     = bool
}
```

### tailscale_dns_nameservers

Global DNS nameservers for the tailnet.

```hcl
resource "tailscale_dns_nameservers" "dns" {
  nameservers = list(string)
}
```

### tailscale_dns_split_nameservers

Split DNS for specific domains.

```hcl
resource "tailscale_dns_split_nameservers" "split" {
  domain      = string
  nameservers = list(string)
}
```

### tailscale_dns_search_paths

DNS search domains.

```hcl
resource "tailscale_dns_search_paths" "search" {
  search_paths = list(string)
}
```

### tailscale_dns_preferences

DNS behavior settings.

```hcl
resource "tailscale_dns_preferences" "prefs" {
  nextdns_enabled = bool
}
```

### tailscale_oauth_client

Creates OAuth clients for API access.

```hcl
resource "tailscale_oauth_client" "client" {
  description = string
  scopes      = list(string)
}
```

### tailscale_webhook

Configures webhook endpoints.

```hcl
resource "tailscale_webhook" "hook" {
  endpointUrl   = string
  provider      = string
  subscriptions = list(string)
  secret        = string  # Optional
}
```

## Data Sources

### tailscale_device

Get a single device by name.

```hcl
data "tailscale_device" "example" {
  name = "device.example.ts.net"
}
```

Attributes: `id`, `node_id`, `name`, `hostname`, `addresses`, `tags`, `authorized`, `user`, `os`, `created`, `expires`, `last_seen`, `client_version`, `update_available`

### tailscale_devices

List devices with filters.

```hcl
data "tailscale_devices" "all" {
  name_prefix = "prod-"

  filter {
    name   = "tags"
    values = ["tag:server"]
  }

  filter {
    name   = "isEphemeral"
    values = ["false"]
  }
}
```

### tailscale_user / tailscale_users

Get user information.

```hcl
data "tailscale_user" "user" {
  id = "user-id"
}

data "tailscale_users" "all" {}
```

### tailscale_acl

Read current ACL configuration.

```hcl
data "tailscale_acl" "current" {}
```

### tailscale_4via6

Calculate 4via6 addresses.

```hcl
data "tailscale_4via6" "example" {
  site_id = 1
  ip      = "10.0.0.1"
}
```

## Environment Variables

| Variable | Description |
|----------|-------------|
| `TAILSCALE_API_KEY` | API key for authentication |
| `TAILSCALE_OAUTH_CLIENT_ID` | OAuth client ID |
| `TAILSCALE_OAUTH_CLIENT_SECRET` | OAuth client secret |
| `TAILSCALE_BASE_URL` | Custom API endpoint |

## Import Commands

```bash
# ACL
terraform import tailscale_acl.main acl

# Device routes (use node_id)
terraform import tailscale_device_subnet_routes.router nodeidCNTRL

# Device tags
terraform import tailscale_device_tags.tags nodeidCNTRL

# Auth key
terraform import tailscale_tailnet_key.key 123456789

# DNS
terraform import tailscale_dns_nameservers.dns dns_nameservers

# Tailnet settings
terraform import tailscale_tailnet_settings.settings tailnet_settings

# OAuth client
terraform import tailscale_oauth_client.client client-id
```