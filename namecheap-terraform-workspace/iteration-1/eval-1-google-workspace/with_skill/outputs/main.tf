terraform {
  required_providers {
    namecheap = {
      source  = "namecheap/namecheap"
      version = ">= 2.0.0"
    }
  }
}

provider "namecheap" {
  user_name   = var.namecheap_user_name
  api_user    = var.namecheap_api_user
  api_key     = var.namecheap_api_key
  client_ip   = var.namecheap_client_ip
  use_sandbox = false
}

/*
  DNS configuration for example.com using Namecheap DNS records:
  - Apex A record -> 192.0.2.100
  - www A record -> 192.0.2.100
  - Google Workspace MX records
  - SPF TXT record for Google SPF
*/
resource "namecheap_domain_records" "google_workspace" {
  domain     = "example.com"
  mode       = "OVERWRITE"
  email_type = "MX"

  # Apex A record
  record {
    hostname = "@"
    type     = "A"
    address  = "192.0.2.100"
    ttl      = 300
  }

  # WWW subdomain A record
  record {
    hostname = "www"
    type     = "A"
    address  = "192.0.2.100"
    ttl      = 300
  }

  # Google Workspace MX records
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
    mx_pref  = 5
  }
  record {
    hostname = "@"
    type     = "MX"
    address  = "alt3.aspmx.l.google.com."
    mx_pref  = 10
  }
  record {
    hostname = "@"
    type     = "MX"
    address  = "alt4.aspmx.l.google.com."
    mx_pref  = 10
  }

  # SPF for Google Workspace
  record {
    hostname = "@"
    type     = "TXT"
    address  = "v=spf1 include:_spf.google.com ~all"
  }
}

output "domain" {
  value = "example.com"
}
