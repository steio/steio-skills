---
name: namecheap-terraform
description: Manages Namecheap DNS records and nameservers using Terraform. Use when configuring DNS records (A, AAAA, CNAME, MX, TXT, NS, CAA, ALIAS, URL), setting up domain nameservers, email routing (MX/MXE), migrating DNS to infrastructure-as-code, troubleshooting Namecheap API authentication, or working with the namecheap/namecheap Terraform provider. Make sure to use this skill whenever the user mentions Namecheap DNS, domain records, or wants to manage domains with Terraform.
license: Apache-2.0
metadata:
  author: community
  version: "1.0.0"
  provider: namecheap/namecheap
  provider-version: ">= 2.0.0"
---

# Namecheap Terraform Provider

Manage Namecheap domain DNS records and nameservers using Terraform infrastructure-as-code.

## Quick Start

### 1. Prerequisites Setup

Before using this provider, complete these steps in your Namecheap account:

1. **Enable API Access**: Profile → Tools → Namecheap API Access → Enable
2. **Whitelist IP**: Profile → Tools → API Access → Whitelisted IPs → Add your static IP
3. **Copy API Key**: Save the API key shown after enabling

### 2. Provider Configuration

```hcl
terraform {
  required_providers {
    namecheap = {
      source  = "namecheap/namecheap"
      version = ">= 2.0.0"
    }
  }
}

provider "namecheap" {
  user_name   = "your_username"
  api_user    = "your_username"
  api_key     = "your_api_key"
  client_ip   = "203.0.113.45"
  use_sandbox = false
}
```

### 3. Environment Variables (Recommended)

```bash
export NAMECHEAP_USER_NAME="your_username"
export NAMECHEAP_API_USER="your_username"
export NAMECHEAP_API_KEY="your_api_key"
export NAMECHEAP_CLIENT_IP="203.0.113.45"
```

```hcl
provider "namecheap" {}  # Uses environment variables
```

## Resource: namecheap_domain_records

The provider has a single resource that manages DNS records OR nameservers (mutually exclusive).

### Arguments

| Argument | Required | Description |
|----------|----------|-------------|
| `domain` | Yes | Domain name in your account |
| `mode` | No | `MERGE` (default) or `OVERWRITE` |
| `email_type` | No | `NONE`, `FWD`, `MXE`, `MX`, `OX`, `GMAIL` |
| `record` | No | DNS record blocks (conflicts with `nameservers`) |
| `nameservers` | No | Custom nameservers list (conflicts with `record`) |

### Record Block

```hcl
record {
  hostname = "www"        # Required: subdomain or @ for apex
  type     = "A"          # Required: A, AAAA, CNAME, MX, TXT, NS, CAA, ALIAS, URL, URL301, FRAME
  address  = "192.0.2.1"  # Required: IP or URL
  ttl      = 1800         # Optional: 60-60000 seconds (default: 1800)
  mx_pref  = 10           # Optional: MX preference (MX records only)
}
```

## Mode: MERGE vs OVERWRITE

Understanding the difference is critical:

### MERGE Mode (Default)

- Multiple Terraform configs can manage different records on the same domain
- Only manages records explicitly defined in the resource
- Preserves manually configured records not in Terraform
- Best for gradual IaC adoption

```hcl
# Only manages the 'blog' record, other records unchanged
resource "namecheap_domain_records" "blog" {
  domain = "example.com"
  mode   = "MERGE"

  record {
    hostname = "blog"
    type     = "A"
    address  = "192.0.2.10"
  }
}
```

### OVERWRITE Mode

- Single config owns ALL records for the domain
- Removes any records not defined in the resource
- Best for complete declarative control
- **Warning**: Deletes manually created records!

```hcl
# Owns ALL records - removes anything not defined
resource "namecheap_domain_records" "main" {
  domain = "example.com"
  mode   = "OVERWRITE"

  record {
    hostname = "@"
    type     = "A"
    address  = "192.0.2.1"
  }
}
```

## DNS Record Types

| Type | Use Case | Address Format |
|------|----------|----------------|
| `A` | IPv4 address | `192.0.2.1` |
| `AAAA` | IPv6 address | `2001:db8::1` |
| `CNAME` | Alias to domain | `example.com.` (trailing dot) |
| `ALIAS` | Apex domain alias | `cdn.example.net.` |
| `MX` | Mail server | `mail.example.com.` + `mx_pref` |
| `MXE` | Mail IP forwarding | `203.0.113.88` |
| `NS` | Subdomain delegation | `ns1.example.com.` |
| `TXT` | SPF, DKIM, verification | `v=spf1 include:...` |
| `CAA` | Certificate authority | `0 issue "letsencrypt.org"` |
| `URL` | HTTP 302 redirect | `https://example.com` |
| `URL301` | HTTP 301 redirect | `https://example.com` |
| `FRAME` | URL masking | `https://example.com` |

## Common Patterns

### Complete Website with Email

```hcl
resource "namecheap_domain_records" "website" {
  domain     = "example.com"
  mode       = "OVERWRITE"
  email_type = "MX"

  # Apex A record
  record {
    hostname = "@"
    type     = "A"
    address  = "192.0.2.1"
    ttl      = 300
  }

  # WWW subdomain
  record {
    hostname = "www"
    type     = "CNAME"
    address  = "example.com."
  }

  # Mail servers
  record {
    hostname = "@"
    type     = "MX"
    address  = "mail.example.com."
    mx_pref  = 10
  }

  # SPF
  record {
    hostname = "@"
    type     = "TXT"
    address  = "v=spf1 include:_spf.google.com ~all"
  }

  # DKIM
  record {
    hostname = "default._domainkey"
    type     = "TXT"
    address  = "v=DKIM1; k=rsa; p=MIGfMA0GCSqGSIb3DQEBA..."
  }

  # DMARC
  record {
    hostname = "_dmarc"
    type     = "TXT"
    address  = "v=DMARC1; p=quarantine; rua=mailto:dmarc@example.com"
  }

  # CAA for Let's Encrypt
  record {
    hostname = "@"
    type     = "CAA"
    address  = "0 issue \"letsencrypt.org\""
  }
}
```

### Google Workspace Setup

```hcl
resource "namecheap_domain_records" "google_workspace" {
  domain     = "example.com"
  mode       = "OVERWRITE"
  email_type = "MX"

  record {
    hostname = "@"
    type     = "MX"
    address  = "aspmx.l.google.com."
    mx_pref  = 1
  }

  record {
    hostname = "@"
    type     = "MX"
    address  = "alt1.aspmx.l.google.com."
    mx_pref  = 5
  }

  record {
    hostname = "@"
    type     = "MX"
    address  = "alt2.aspmx.l.google.com."
    mx_pref  = 10
  }

  record {
    hostname = "@"
    type     = "TXT"
    address  = "v=spf1 include:_spf.google.com ~all"
  }
}
```

### Custom Nameservers

```hcl
resource "namecheap_domain_records" "custom_ns" {
  domain = "example.com"
  mode   = "OVERWRITE"

  nameservers = [
    "ns1.mydnsprovider.com",
    "ns2.mydnsprovider.com",
  ]
}
```

## Critical Rules

### 1. Use Lowercase

Always use lowercase for `hostname`, `address`, and `nameservers` to prevent undefined behavior.

```hcl
# Correct
record {
  hostname = "www"
  address  = "example.com."
}

# Wrong - may cause issues
record {
  hostname = "WWW"
  address  = "Example.Com."
}
```

### 2. Trailing Dots for FQDNs

CNAME, ALIAS, NS, and MX addresses must end with a trailing dot:

```hcl
record {
  hostname = "www"
  type     = "CNAME"
  address  = "example.com."  # Trailing dot required
}
```

### 3. Records and Nameservers Are Mutually Exclusive

You cannot define both `record` blocks and `nameservers` in the same resource.

### 4. SRV Records Not Supported

The Namecheap API does not support SRV records. Use Cloudflare or Route 53 if SRV records are required.

## Troubleshooting

| Error | Solution |
|-------|----------|
| "API key is invalid" | Verify API key in dashboard, ensure API access is enabled |
| "Client IP is not whitelisted" | Add your IP at Profile → Tools → API Access → Whitelisted IPs |
| "Domain not found" | Verify domain is in your account, check spelling, ensure domain is active |
| "Record already exists" (MERGE) | Import existing record: `terraform import namecheap_domain_records.main example.com` |

## Import Existing Configuration

```bash
terraform import namecheap_domain_records.main example.com
```

Imported resources default to `MERGE` mode.

## Sandbox Testing

```hcl
provider "namecheap" {
  use_sandbox = true  # Uses sandbox.namecheap.com
}
```

Sign up at [sandbox.namecheap.com](https://www.sandbox.namecheap.com) for a free testing account.

## Additional Resources

- [Provider Reference](docs/provider-reference.md) - Complete argument reference
- [DNS Record Examples](docs/dns-examples.md) - Detailed examples for each record type
- [Migration Guide](docs/migration.md) - Migrating from v1.x to v2.x