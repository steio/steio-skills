# Provider Reference

Complete reference for the Namecheap Terraform Provider.

## Provider Configuration

| Argument | Required | Environment Variable | Description |
|----------|----------|---------------------|-------------|
| `user_name` | Yes | `NAMECHEAP_USER_NAME` | Your Namecheap username |
| `api_user` | Yes | `NAMECHEAP_API_USER` | API user (usually same as username) |
| `api_key` | Yes | `NAMECHEAP_API_KEY` | API key from Namecheap dashboard |
| `client_ip` | No | `NAMECHEAP_CLIENT_IP` | Your whitelisted IP (default: "0.0.0.0") |
| `use_sandbox` | No | `NAMECHEAP_USE_SANDBOX` | Use sandbox API (default: false) |

## namecheap_domain_records Resource

### Arguments

| Argument | Type | Required | Description |
|----------|------|----------|-------------|
| `domain` | string | Yes | Domain name in your Namecheap account |
| `mode` | string | No | `MERGE` (default) or `OVERWRITE` |
| `email_type` | string | No | Email routing type |
| `record` | set | No | DNS record blocks |
| `nameservers` | set | No | Custom nameservers list |

### email_type Values

| Value | Description |
|-------|-------------|
| `NONE` | No email service (default) |
| `FWD` | Email forwarding |
| `MXE` | MX Easy (mail forwarding to IP) |
| `MX` | Custom MX records |
| `OX` | Open-Xchange email |
| `GMAIL` | Google Workspace |

### record Block

| Argument | Type | Required | Description |
|----------|------|----------|-------------|
| `hostname` | string | Yes | Subdomain or `@` for apex |
| `type` | string | Yes | Record type |
| `address` | string | Yes | IP address or URL |
| `ttl` | int | No | Time to live (60-60000, default: 1800) |
| `mx_pref` | int | No | MX preference (MX records only, default: 10) |

### Record Types

| Type | Description | Address Format |
|------|-------------|----------------|
| `A` | IPv4 address | `192.0.2.1` |
| `AAAA` | IPv6 address | `2001:db8::1` |
| `ALIAS` | Apex alias (Namecheap-specific) | `cdn.example.com.` |
| `CAA` | Certificate Authority Authorization | `0 issue "letsencrypt.org"` |
| `CNAME` | Canonical name | `example.com.` |
| `FRAME` | URL masking (iframe) | `https://example.com` |
| `MX` | Mail exchange | `mail.example.com.` |
| `MXE` | MX Easy (IP forwarding) | `192.0.2.1` |
| `NS` | Nameserver (subdomains only) | `ns1.example.com.` |
| `TXT` | Text record | `v=spf1 ...` |
| `URL` | HTTP 302 redirect | `https://example.com` |
| `URL301` | HTTP 301 redirect | `https://example.com` |

### Import

```bash
terraform import namecheap_domain_records.example example.com
```

### Timeouts

No customizable timeouts. API operations typically complete within 30 seconds.