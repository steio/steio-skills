# DNS Record Examples

Detailed examples for each DNS record type supported by the Namecheap Terraform Provider.

## A Record (IPv4)

Maps a hostname to an IPv4 address.

```hcl
record {
  hostname = "@"
  type     = "A"
  address  = "192.0.2.1"
  ttl      = 300
}

record {
  hostname = "api"
  type     = "A"
  address  = "192.0.2.10"
  ttl      = 300
}
```

## AAAA Record (IPv6)

Maps a hostname to an IPv6 address.

```hcl
record {
  hostname = "@"
  type     = "AAAA"
  address  = "2001:0db8:85a3:0000:0000:8a2e:0370:7334"
  ttl      = 300
}
```

## CNAME Record

Creates an alias pointing to another domain. Note the trailing dot.

```hcl
record {
  hostname = "www"
  type     = "CNAME"
  address  = "example.com."
  ttl      = 3600
}

record {
  hostname = "blog"
  type     = "CNAME"
  address  = "blog.example.org."
  ttl      = 3600
}
```

## ALIAS Record

Namecheap-specific record for apex domain aliasing. Useful for pointing apex to CDN.

```hcl
record {
  hostname = "@"
  type     = "ALIAS"
  address  = "cdn.example.net."
  ttl      = 300
}
```

## MX Record

Mail server configuration. Requires `mx_pref` for priority.

```hcl
resource "namecheap_domain_records" "email" {
  domain     = "example.com"
  mode       = "OVERWRITE"
  email_type = "MX"

  record {
    hostname = "@"
    type     = "MX"
    address  = "mail.example.com."
    mx_pref  = 10
    ttl      = 3600
  }

  record {
    hostname = "@"
    type     = "MX"
    address  = "mail2.example.com."
    mx_pref  = 20
    ttl      = 3600
  }
}
```

## MXE Record

MX Easy - forwards all email to a specific IP address.

```hcl
resource "namecheap_domain_records" "mxe" {
  domain     = "example.com"
  mode       = "OVERWRITE"
  email_type = "MXE"

  record {
    hostname = "@"
    type     = "MXE"
    address  = "203.0.113.88"
  }
}
```

## TXT Record

Text records for SPF, DKIM, domain verification, etc.

```hcl
# SPF record
record {
  hostname = "@"
  type     = "TXT"
  address  = "v=spf1 include:_spf.google.com ~all"
}

# DKIM record
record {
  hostname = "default._domainkey"
  type     = "TXT"
  address  = "v=DKIM1; k=rsa; p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQC..."
}

# DMARC record
record {
  hostname = "_dmarc"
  type     = "TXT"
  address  = "v=DMARC1; p=quarantine; rua=mailto:dmarc@example.com"
}

# Domain verification
record {
  hostname = "@"
  type     = "TXT"
  address  = "google-site-verification=ABC123XYZ"
}
```

## NS Record

Nameserver delegation for subdomains only.

```hcl
record {
  hostname = "subdomain"
  type     = "NS"
  address  = "ns1.subdomain-host.com."
}

record {
  hostname = "subdomain"
  type     = "NS"
  address  = "ns2.subdomain-host.com."
}
```

## CAA Record

Certificate Authority Authorization - controls which CAs can issue certificates.

```hcl
# Allow Let's Encrypt only
record {
  hostname = "@"
  type     = "CAA"
  address  = "0 issue \"letsencrypt.org\""
}

# Allow multiple CAs
record {
  hostname = "@"
  type     = "CAA"
  address  = "0 issue \"letsencrypt.org\""
}

record {
  hostname = "@"
  type     = "CAA"
  address  = "0 issue \"digicert.com\""
}

# Report violations
record {
  hostname = "@"
  type     = "CAA"
  address  = "0 iodef \"mailto:security@example.com\""
}
```

## URL Redirect (HTTP 302)

Temporary redirect.

```hcl
record {
  hostname = "promo"
  type     = "URL"
  address  = "https://special-offer.example.com"
}
```

## URL301 Redirect (HTTP 301)

Permanent redirect - better for SEO.

```hcl
record {
  hostname = "old-page"
  type     = "URL301"
  address  = "https://example.com/new-page"
}
```

## FRAME Record

URL masking via iframe.

```hcl
record {
  hostname = "masked"
  type     = "FRAME"
  address  = "https://internal-app.company.com"
}
```

## Complete Example: Production Website

```hcl
resource "namecheap_domain_records" "production" {
  domain     = "example.com"
  mode       = "OVERWRITE"
  email_type = "MX"

  # Web server
  record {
    hostname = "@"
    type     = "A"
    address  = "192.0.2.1"
    ttl      = 300
  }

  record {
    hostname = "www"
    type     = "CNAME"
    address  = "example.com."
  }

  # API subdomain
  record {
    hostname = "api"
    type     = "A"
    address  = "192.0.2.10"
  }

  # Mail
  record {
    hostname = "@"
    type     = "MX"
    address  = "mail.example.com."
    mx_pref  = 10
  }

  record {
    hostname = "@"
    type     = "MX"
    address  = "mail2.example.com."
    mx_pref  = 20
  }

  # Email authentication
  record {
    hostname = "@"
    type     = "TXT"
    address  = "v=spf1 include:_spf.google.com ~all"
  }

  record {
    hostname = "default._domainkey"
    type     = "TXT"
    address  = "v=DKIM1; k=rsa; p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQC..."
  }

  record {
    hostname = "_dmarc"
    type     = "TXT"
    address  = "v=DMARC1; p=reject; rua=mailto:dmarc@example.com"
  }

  # Certificate authority
  record {
    hostname = "@"
    type     = "CAA"
    address  = "0 issue \"letsencrypt.org\""
  }
}
```