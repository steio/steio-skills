# Migration Guide

## Migrating from v1.x to v2.0.0

The v2.0.0 release introduced breaking changes to provider configuration.

### Provider Configuration Changes

| v1.x (Old) | v2.x (New) |
|------------|------------|
| `username` | `user_name` |
| `token` | `api_key` |
| `ip` | `client_ip` |

### Example Migration

**Before (v1.x):**

```hcl
provider "namecheap" {
  username = "your_username"
  api_user = "your_username"
  token    = "your_api_key"
  ip       = "203.0.113.45"
  use_sandbox = false
}
```

**After (v2.x):**

```hcl
provider "namecheap" {
  user_name = "your_username"
  api_user  = "your_username"
  api_key   = "your_api_key"
  client_ip = "203.0.113.45"
  use_sandbox = false
}
```

### Environment Variables

| Old Variable | New Variable |
|--------------|--------------|
| `NAMECHEAP_USERNAME` | `NAMECHEAP_USER_NAME` |
| `NAMECHEAP_TOKEN` | `NAMECHEAP_API_KEY` |
| `NAMECHEAP_IP` | `NAMECHEAP_CLIENT_IP` |

## Migrating from Manual Configuration

### Step 1: Import Existing Records

```bash
terraform import namecheap_domain_records.main example.com
```

### Step 2: Review State

```bash
terraform show
```

### Step 3: Create Configuration

Write Terraform configuration matching the imported state.

### Step 4: Verify No Changes

```bash
terraform plan
# Should show: No changes
```

### Step 5: Switch to OVERWRITE (Optional)

Once confident, switch to OVERWRITE mode for full control:

```hcl
resource "namecheap_domain_records" "main" {
  domain = "example.com"
  mode   = "OVERWRITE"  # Changed from MERGE
  # ... records
}
```

## Migrating from Another DNS Provider

When switching from Cloudflare, Route 53, or another provider:

1. Export records from current provider
2. Create Terraform configuration in OVERWRITE mode
3. Update nameservers at Namecheap to use Namecheap DNS
4. Wait for propagation (up to 48 hours)
5. Apply Terraform configuration