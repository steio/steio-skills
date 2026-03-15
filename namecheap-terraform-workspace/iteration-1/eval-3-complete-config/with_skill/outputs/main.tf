terraform {
  required_providers {
    namecheap = {
      source  = "namecheap/namecheap"
      version = "~> 2.0"
    }
  }
}

variable "NAMECHEAP_API_USER" {
  description = "Namecheap API username"
  type        = string
  default     = ""
}
variable "NAMECHEAP_API_KEY" {
  description = "Namecheap API key"
  type        = string
  default     = ""
}
variable "NAMECHEAP_CLIENT_IP" {
  description = "Namecheap API client IP"
  type        = string
  default     = ""
}

provider "namecheap" {
  api_user  = var.NAMECHEAP_API_USER
  api_key   = var.NAMECHEAP_API_KEY
  client_ip = var.NAMECHEAP_CLIENT_IP
}

resource "namecheap_record" "A_root" {
  domain = "myapp.io"
  host   = "@"
  type   = "A"
  data   = "10.0.0.1"
  ttl    = 600
}

resource "namecheap_record" "CNAME_www" {
  domain = "myapp.io"
  host   = "www"
  type   = "CNAME"
  data   = "myapp.io."
  ttl    = 600
}

resource "namecheap_record" "MX_mail" {
  domain = "myapp.io"
  host   = "@"
  type   = "MX"
  data   = "10 mail.myapp.io"
  ttl    = 600
}

resource "namecheap_record" "TXT_spf" {
  domain = "myapp.io"
  host   = "@"
  type   = "TXT"
  data   = "\"v=spf1 include:mail.myapp.io ~all\""
  ttl    = 600
}

resource "namecheap_record" "TXT_dmarc" {
  domain = "myapp.io"
  host   = "_dmarc"
  type   = "TXT"
  data   = "\"v=DMARC1; p=none; rua=mailto:postmaster@myapp.io\""
  ttl    = 600
}

resource "namecheap_record" "CAA_letsencrypt" {
  domain = "myapp.io"
  host   = "@"
  type   = "CAA"
  data   = "0 issue \"letsencrypt.org\""
  ttl    = 600
}

resource "namecheap_record" "CAA_lets_encrypt_wildcard" {
  domain = "myapp.io"
  host   = "@"
  type   = "CAA"
  data   = "0 issuewild \"letsencrypt.org\""
  ttl    = 600
}

output "domain" {
  value       = "myapp.io"
  description = "Managed domain"
}
