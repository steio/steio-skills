// OVERWRITE mode: this Terraform config uses create_before_destroy lifecycles
// to overwrite DNS records where needed. Point your Namecheap API credentials in variables.tf.
terraform {
  required_providers {
    namecheap = {
      source  = "namecheap/namecheap"
      version = "~> 2.0"
    }
  }
  required_version = ">= 1.3.0"
}

provider "namecheap" {
  api_user  = var.namecheap_api_user
  api_key   = var.namecheap_api_key
  user_name = var.namecheap_user_name
  client_ip = var.client_ip
}

resource "namecheap_domain" "domain" {
  name = "myapp.io"
}

// A record at apex
resource "namecheap_record" "a_root" {
  domain  = namecheap_domain.domain.name
  host    = "@"
  type    = "A"
  address = "10.0.0.1"
  ttl     = 600
  lifecycle { create_before_destroy = true }
}

// CNAME for www -> apex
resource "namecheap_record" "www" {
  domain  = namecheap_domain.domain.name
  host    = "www"
  type    = "CNAME"
  address = "myapp.io"
  ttl     = 600
  lifecycle { create_before_destroy = true }
}

// MX for email: mail.myapp.io
resource "namecheap_record" "mx" {
  domain   = namecheap_domain.domain.name
  host     = "@"
  type     = "MX"
  address  = "mail.myapp.io"
  priority = 10
  ttl      = 600
  lifecycle { create_before_destroy = true }
}

// SPF (TXT) record
resource "namecheap_record" "spf" {
  domain  = namecheap_domain.domain.name
  host    = "@"
  type    = "TXT"
  address = "v=spf1 mx ~all"
  ttl     = 600
  lifecycle { create_before_destroy = true }
}

// DMARC (TXT) record at _dmarc
resource "namecheap_record" "dmarc" {
  domain  = namecheap_domain.domain.name
  host    = "_dmarc"
  type    = "TXT"
  address = "v=DMARC1; p=none; rua=mailto:postmaster@myapp.io"
  ttl     = 600
  lifecycle { create_before_destroy = true }
}

// CAA for Let's Encrypt
resource "namecheap_record" "caa" {
  domain  = namecheap_domain.domain.name
  host    = "@"
  type    = "CAA"
  address = "0 issue \"letsencrypt.org\""
  ttl     = 600
  lifecycle { create_before_destroy = true }
}

output "apex_A_address" { value = namecheap_record.a_root.address }
output "www_CNAME"        { value = namecheap_record.www.address }
output "mx_address"       { value = namecheap_record.mx.address }
output "spf_address"      { value = namecheap_record.spf.address }
output "dmarc_address"    { value = namecheap_record.dmarc.address }
output "caa_address"      { value = namecheap_record.caa.address }
