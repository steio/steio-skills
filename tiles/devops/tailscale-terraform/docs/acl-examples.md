# ACL Policy File Examples

Tailscale ACLs control access between devices in your tailnet. The policy file uses JSON or HuJSON format.

## Basic ACL Structure

```json
{
  "acls": [...],
  "tagOwners": {...},
  "groups": {...},
  "hosts": {...},
  "tests": [...],
  "grants": [...]
}
```

## Common Patterns

### Allow All (Development)

```json
{
  "acls": [
    {
      "action": "accept",
      "src": ["*"],
      "dst": ["*:*"]
    }
  ]
}
```

### Admin Access Only

```json
{
  "groups": {
    "group:admin": ["alice@example.com", "bob@example.com"]
  },
  "acls": [
    {
      "action": "accept",
      "src": ["group:admin"],
      "dst": ["*:*"]
    }
  ]
}
```

### Server Isolation

```json
{
  "tagOwners": {
    "tag:server": ["group:admin"],
    "tag:db": ["group:admin"]
  },
  "acls": [
    {
      "action": "accept",
      "src": ["tag:server"],
      "dst": ["tag:db:5432"]
    },
    {
      "action": "accept",
      "src": ["group:admin"],
      "dst": ["tag:server:*", "tag:db:*"]
    }
  ]
}
```

### Subnet Router Access

```json
{
  "tagOwners": {
    "tag:router": ["group:admin"]
  },
  "acls": [
    {
      "action": "accept",
      "src": ["*"],
      "dst": ["tag:router:*"]
    }
  ]
}
```

### Exit Node Control

```json
{
  "tagOwners": {
    "tag:exit-node": ["group:admin"]
  },
  "acls": [
    {
      "action": "accept",
      "src": ["group:trusted"],
      "dst": ["tag:exit-node:*"]
    }
  ]
}
```

### Environment-Based Access

```json
{
  "tagOwners": {
    "tag:prod": ["group:ops"],
    "tag:staging": ["group:dev"],
    "tag:dev": ["group:dev"]
  },
  "acls": [
    {
      "action": "accept",
      "src": ["group:ops"],
      "dst": ["tag:prod:*", "tag:staging:*", "tag:dev:*"]
    },
    {
      "action": "accept",
      "src": ["group:dev"],
      "dst": ["tag:staging:*", "tag:dev:*"]
    }
  ]
}
```

### Host Aliases

```json
{
  "hosts": {
    "production-db": "10.0.0.5",
    "staging-db": "10.1.0.5",
    "internal": "10.0.0.0/8"
  },
  "acls": [
    {
      "action": "accept",
      "src": ["group:ops"],
      "dst": ["production-db:5432"]
    }
  ]
}
```

### Port Restrictions

```json
{
  "acls": [
    {
      "action": "accept",
      "src": ["group:developers"],
      "dst": ["tag:server:22,443"]
    },
    {
      "action": "accept",
      "src": ["tag:web"],
      "dst": ["tag:db:5432"]
    }
  ]
}
```

### Auto Approvers for Routes

```json
{
  "tagOwners": {
    "tag:router": ["group:admin"]
  },
  "autoApprovers": {
    "routes": {
      "10.0.0.0/16": ["tag:router"],
      "192.168.1.0/24": ["tag:router"]
    },
    "exitNode": ["tag:exit-node"]
  },
  "acls": [
    {
      "action": "accept",
      "src": ["*"],
      "dst": ["*:*"]
    }
  ]
}
```

### With Tests

```json
{
  "tagOwners": {
    "tag:web": ["group:admin"],
    "tag:db": ["group:admin"]
  },
  "acls": [
    {
      "action": "accept",
      "src": ["tag:web"],
      "dst": ["tag:db:5432"]
    },
    {
      "action": "accept",
      "src": ["group:admin"],
      "dst": ["*:*"]
    }
  ],
  "tests": [
    {
      "src": "tag:web",
      "accept": ["tag:db:5432"],
      "deny": ["tag:db:22"]
    },
    {
      "src": "group:admin",
      "accept": ["tag:web:22", "tag:db:5432"]
    }
  ]
}
```

## Terraform Usage

```hcl
resource "tailscale_acl" "main" {
  acl = jsonencode({
    tagOwners = {
      "tag:server" = ["group:admin"]
    }
    acls = [
      {
        action = "accept"
        src    = ["group:admin"]
        dst    = ["*:*"]
      }
    ]
    tests = [
      {
        src    = "group:admin"
        accept = ["tag:server:22"]
      }
    ]
  })
}
```

### HuJSON with Comments

```hcl
resource "tailscale_acl" "main" {
  acl = <<EOF
  {
    // Admin users have full access
    "acls": [
      {
        "action": "accept",
        "src": ["group:admin"],
        "dst": ["*:*"]
      }
    ]
  }
  EOF
}
```

## ACL Validation

If the policy contains `tests`, Tailscale validates before applying:

```hcl
resource "tailscale_acl" "main" {
  acl = jsonencode({
    acls = [...]
    tests = [
      {
        src    = "user@example.com"
        accept = ["tag:server:22"]
        deny   = ["tag:db:*"]
      }
    ]
  })
}
```

## Import Existing ACL

```bash
terraform import tailscale_acl.main acl
```

Or use `overwrite_existing_content` (caution!):

```hcl
resource "tailscale_acl" "main" {
  acl                        = jsonencode({...})
  overwrite_existing_content = true  # Skips import requirement
}
```