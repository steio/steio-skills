terraform {
  required_providers {
    namecheap = {
      source  = "namecheap/namecheap"
      version = "~> 2.0"
    }
  }
}

provider "namecheap" {
  api_user  = var.namecheap_user
  api_key   = var.namecheap_api_key
  client_ip = var.namecheap_client_ip
}

variable "namecheap_user" {
  type = string
}
variable "namecheap_api_key" {
  type = string
}
variable "namecheap_client_ip" {
  type = string
}
variable "domain_name" {
  type    = string
  default = "example.com"
}
variable "ip_address" {
  type    = string
  default = "192.0.2.100"
}

locals {
  domain = var.domain_name
  ip     = var.ip_address
}

resource "namecheap_domain" "domain" {
  domain = local.domain
  years  = 1
}

resource "namecheap_domain_dns" "zone" {
  domain = local.domain

  records = [
    { host = "@", type = "A", address = local.ip, ttl = 300 },
    { host = "www", type = "A", address = local.ip, ttl = 300 },
    { host = "@", type = "MX", address = "1 ASPMX.L.GOOGLE.COM.", ttl = 300 },
    { host = "@", type = "MX", address = "5 ALT1.ASPMX.L.GOOGLE.COM.", ttl = 300 },
    { host = "@", type = "MX", address = "5 ALT2.ASPMX.L.GOOGLE.COM.", ttl = 300 },
    { host = "@", type = "MX", address = "10 ALT3.ASPMX.L.GOOGLE.COM.", ttl = 300 },
    { host = "@", type = "MX", address = "10 ALT4.ASPMX.L.GOOGLE.COM.", ttl = 300 },
    { host = "@", type = "TXT", address = "v=spf1 include:_spf.google.com ~all", ttl = 300 },
  ]
}

output "domain_name" {
  value = local.domain
}
output "apex_ip" {
  value = local.ip
}
