---
name: tailscale-terraform
description: Manages Tailscale networking infrastructure using Terraform/OpenTofu. Use when configuring Tailscale VPN resources (ACLs, devices, DNS, auth keys, subnet routers, exit nodes), managing tailnet settings, deploying Tailscale on cloud VMs with cloud-init, or working with the tailscale/terraform-provider-tailscale and tailscale/terraform-cloudinit-tailscale modules. Make sure to use this skill whenever the user mentions Tailscale, WireGuard VPN, mesh networking, subnet routers, exit nodes, or wants to manage Tailscale with Terraform.
license: MIT
metadata:
  author: community
  version: "1.0.0"
  provider: tailscale/tailscale
  provider-version: ">= 0.16.0"
---

# Tailscale Terraform Provider

Manage Tailscale mesh VPN infrastructure using Terraform infrastructure-as-code. Supports ACLs, device management, DNS configuration, auth keys, subnet routers, exit nodes, and cloud-init deployments.

## Quick Start

### 1. Prerequisites Setup

Before using this provider:

1. **Get API Key**: Go to [Tailscale Admin Console](https://login.tailscale.com/admin/settings/keys)
2. **Create API Key**: Settings → Keys → Generate API Key
3. **Note**: API keys expire and should be rotated

### 2. Provider Configuration

```hcl
terraform {
  required_providers {
    tailscale = {
      source  = "tailscale/tailscale"
      version = "~> 0.16"
    }
  }
}

provider "tailscale" {
  api_key = "tskey-api-..."
}
```

### 3. OAuth Authentication (Recommended for CI/CD)

```hcl
provider "tailscale" {
  oauth_client_id     = "..."
  oauth_client_secret = "tskey-client-..."
}
```

### 4. Environment Variables (Recommended)

```bash
export TAILSCALE_API_KEY="tskey-api-..."
# or for OAuth:
export TAILSCALE_OAUTH_CLIENT_ID="..."
export TAILSCALE_OAUTH_CLIENT_SECRET="tskey-client-..."
```

```hcl
provider "tailscale" {}  # Uses environment variables
```

## Resources Overview

| Resource | Purpose |
|----------|---------|
| `tailscale_acl` | Policy file (ACLs, grants, tests) |
| `tailscale_tailnet_key` | Pre-authentication keys |
| `tailscale_tailnet_settings` | Tailnet configuration |
| `tailscale_device_subnet_routes` | Subnet routes and exit nodes |
| `tailscale_device_tags` | Device tagging |
| `tailscale_device_authorization` | Device approval |
| `tailscale_dns_nameservers` | Global DNS nameservers |
| `tailscale_dns_split_nameservers` | Split DNS configuration |
| `tailscale_dns_search_paths` | DNS search domains |
| `tailscale_dns_preferences` | DNS settings |
| `tailscale_oauth_client` | OAuth client management |
| `tailscale_webhook` | Webhook endpoints |
| `tailscale_contacts` | Tailnet contacts |
| `tailscale_logstream_configuration` | Log streaming |
| `tailscale_posture_integration` | Device posture |

## Data Sources

| Data Source | Purpose |
|-------------|---------|
| `tailscale_device` | Single device by name |
| `tailscale_devices` | List of devices with filters |
| `tailscale_user` | Single user |
| `tailscale_users` | List of users |
| `tailscale_acl` | Current ACL configuration |
| `tailscale_4via6` | 4via6 address mapping |

## Common Patterns

### Auth Key for Cloud Servers

```hcl
resource "tailscale_tailnet_key" "server_key" {
  reusable      = true
  ephemeral     = false
  preauthorized = true
  expiry        = 7776000  # 90 days
  description   = "Server authentication key"
  tags          = ["tag:server"]
}
```

### Subnet Router Configuration

```hcl
data "tailscale_device" "router" {
  name = "router.example.ts.net"
}

resource "tailscale_device_subnet_routes" "router_routes" {
  device_id = data.tailscale_device.router.node_id
  routes = [
    "10.0.0.0/16",
    "192.168.1.0/24"
  ]
}
```

### Exit Node Setup

```hcl
data "tailscale_device" "exit_node" {
  name = "exit-node.example.ts.net"
}

resource "tailscale_device_subnet_routes" "exit_node_routes" {
  device_id = data.tailscale_device.exit_node.node_id
  routes = [
    "0.0.0.0/0",  # IPv4 exit node
    "::/0"        # IPv6 exit node
  ]
}

resource "tailscale_device_tags" "exit_node_tags" {
  device_id = data.tailscale_device.exit_node.node_id
  tags      = ["tag:exit-node"]
}
```

### ACL Policy with Tests

```hcl
resource "tailscale_acl" "main" {
  acl = jsonencode({
    acls = [
      {
        action = "accept"
        src    = ["tag:admin"]
        dst    = ["*:*"]
      },
      {
        action = "accept"
        src    = ["tag:server"]
        dst    = ["tag:server:*"]
      }
    ]
    tagOwners = {
      "tag:admin"  = ["autogroup:admin"]
      "tag:server" = ["autogroup:admin"]
    }
    tests = [
      {
        src    = "tag:admin"
        accept = ["tag:server:22"]
      }
    ]
  })
}
```

### DNS Configuration

```hcl
resource "tailscale_dns_nameservers" "global" {
  nameservers = [
    "8.8.8.8",
    "8.8.4.4",
    "1.1.1.1"
  ]
}

resource "tailscale_dns_search_paths" "search" {
  search_paths = [
    "example.ts.net",
    "internal.example.com"
  ]
}

resource "tailscale_dns_split_nameservers" "internal" {
  domain = "internal.example.com"
  nameservers = [
    "10.0.0.1",
    "10.0.0.2"
  ]
}
```

### Tailnet Settings

```hcl
resource "tailscale_tailnet_settings" "settings" {
  devices_approval_on           = true
  devices_auto_updates_on       = true
  devices_key_duration_days     = 30
  users_approval_on             = false
  https_enabled                 = true
  posture_identity_collection_on = true
}
```

### Device Management

```hcl
# Get all devices with a prefix
data "tailscale_devices" "servers" {
  name_prefix = "prod-"
  
  filter {
    name   = "tags"
    values = ["tag:server"]
  }
}

# Authorize a device
resource "tailscale_device_authorization" "auth" {
  device_id    = data.tailscale_device.example.node_id
  authorized   = true
}

# Apply tags to a device
resource "tailscale_device_tags" "tags" {
  device_id = data.tailscale_device.example.node_id
  tags      = ["tag:production", "tag:web"]
}

# Disable key expiry for a server
resource "tailscale_device_key" "server_key" {
  device_id          = data.tailscale_device.server.node_id
  key_expiry_disabled = true
}
```

## Cloud-Init Module Usage

Use `terraform-cloudinit-tailscale` for deploying Tailscale on cloud VMs:

```hcl
module "tailscale_cloudinit" {
  source = "github.com/tailscale/terraform-cloudinit-tailscale"

  auth_key             = tailscale_tailnet_key.server_key.key
  hostname             = "my-server"
  advertise_exit_node  = false
  advertise_routes     = ["10.0.0.0/16"]
  accept_routes        = true
  advertise_tags       = ["tag:server"]
  enable_ssh           = true
}

# Use with AWS instance
resource "aws_instance" "server" {
  user_data = module.tailscale_cloudinit.rendered
  # ... other instance config
}
```

### Cloud-Init Module Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `auth_key` | Auth key (or `file:`/`command:` prefix) | Required |
| `hostname` | Instance hostname | `""` |
| `advertise_exit_node` | Advertise as exit node | `false` |
| `advertise_routes` | Routes to advertise | `[]` |
| `advertise_tags` | Tags to advertise | `[]` |
| `accept_routes` | Accept subnet routes | `false` |
| `enable_ssh` | Enable Tailscale SSH | `false` |
| `accept_dns` | Accept DNS from Tailscale | `true` |
| `shields_up` | Block incoming connections | `false` |
| `track` | Tailscale version track | `"stable"` |

## Critical Rules

### 1. Use node_id for Device Operations

Always use the stable `node_id` attribute instead of legacy `id`:

```hcl
# Correct
resource "tailscale_device_tags" "tags" {
  device_id = data.tailscale_device.example.node_id
  tags      = ["tag:server"]
}

# Works but deprecated
resource "tailscale_device_tags" "tags" {
  device_id = data.tailscale_device.example.id  # Legacy
  tags      = ["tag:server"]
}
```

### 2. ACL Overwrites Existing Policy

The `tailscale_acl` resource completely replaces the policy file:

```hcl
# Import existing ACL first
terraform import tailscale_acl.main acl

# Or use overwrite_existing_content (dangerous!)
resource "tailscale_acl" "main" {
  acl                        = jsonencode({...})
  overwrite_existing_content = true
}
```

### 3. Subnet Routes Must Be Advertised First

Routes must be advertised from the device before Terraform can enable them:

```bash
# On the device, advertise routes first:
tailscale up --advertise-routes=10.0.0.0/16
```

Then Terraform can enable them:

```hcl
resource "tailscale_device_subnet_routes" "routes" {
  device_id = data.tailscale_device.router.node_id
  routes    = ["10.0.0.0/16"]
}
```

### 4. Auth Keys Are Sensitive

The `key` attribute is sensitive and only populated on creation:

```hcl
output "auth_key" {
  value     = tailscale_tailnet_key.server_key.key
  sensitive = true
}
```

### 5. Tags Must Start with "tag:"

```hcl
resource "tailscale_device_tags" "tags" {
  device_id = data.tailscale_device.example.node_id
  tags      = ["tag:server", "tag:production"]  # Must include "tag:" prefix
}
```

## Common Workflows

### Setting Up a Subnet Router

1. Create auth key with tags
2. Deploy VM with cloud-init
3. Configure subnet routes
4. Update ACL for access

```hcl
# 1. Auth key
resource "tailscale_tailnet_key" "router_key" {
  reusable      = true
  preauthorized = true
  tags          = ["tag:router"]
}

# 2. Cloud-init for VM
module "router_cloudinit" {
  source           = "github.com/tailscale/terraform-cloudinit-tailscale"
  auth_key         = tailscale_tailnet_key.router_key.key
  advertise_routes = ["10.0.0.0/16"]
  accept_routes    = true
  advertise_tags   = ["tag:router"]
}

# 3. Enable routes (after device appears)
resource "tailscale_device_subnet_routes" "router" {
  device_id = data.tailscale_device.router.node_id
  routes    = ["10.0.0.0/16"]
}

# 4. ACL access
resource "tailscale_acl" "main" {
  acl = jsonencode({
    acls = [
      {
        action = "accept"
        src    = ["*"]
        dst    = ["tag:router:*"]
      }
    ]
  })
}
```

### Device Approval Workflow

```hcl
# Enable device approval
resource "tailscale_tailnet_settings" "settings" {
  devices_approval_on = true
}

# Auto-approve devices with specific tags
resource "tailscale_tailnet_key" "preauth_key" {
  preauthorized = true
  tags          = ["tag:server"]
}
```

## Troubleshooting

| Error | Solution |
|-------|----------|
| "API key is invalid" | Regenerate key, verify it's not expired |
| "device not found" | Device may not be registered yet, use `depends_on` |
| "routes not advertised" | Run `tailscale up --advertise-routes=...` on device first |
| "tag not defined in ACL" | Add tag to `tagOwners` in ACL policy |
| "key already used" | Use `reusable = true` for multi-use keys |
| "not authorized" | Check API key has correct scopes |

## Import Existing Resources

```bash
# ACL
terraform import tailscale_acl.main acl

# Device routes (use node_id)
terraform import tailscale_device_subnet_routes.router nodeidCNTRL

# Device tags
terraform import tailscale_device_tags.tags nodeidCNTRL

# DNS nameservers
terraform import tailscale_dns_nameservers.main dns_nameservers

# Tailnet settings
terraform import tailscale_tailnet_settings.settings tailnet_settings
```

## API Endpoint Configuration

For custom control plane (e.g., Headscale):

```hcl
provider "tailscale" {
  api_key  = "..."
  base_url = "https://headscale.example.com"
}
```

## Additional Resources

- [Provider Reference](docs/provider-reference.md) - Complete argument reference
- [ACL Examples](docs/acl-examples.md) - Policy file patterns
- [Cloud-Init Examples](docs/cloudinit-examples.md) - VM deployment patterns