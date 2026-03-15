# Delegating Domain DNS to Cloudflare via Namecheap Terraform

## Problem/Feature Description

Nexus Payments is migrating all their DNS management from Namecheap's native DNS to Cloudflare, which offers DDoS protection, analytics, and advanced routing rules the team needs for PCI compliance. Their domains are registered through Namecheap and will remain there — only the DNS resolution needs to move to Cloudflare's nameservers.

The infrastructure team manages Namecheap settings with Terraform. They need to update their Terraform configuration for `nexuspayments.com` to point to Cloudflare's assigned nameservers: `nora.ns.cloudflare.com` and `rod.ns.cloudflare.com`. Once this is applied, all DNS records will be managed in Cloudflare, not Namecheap.

A junior engineer on the team has drafted a configuration that they're not sure is correct. Review and correct it, then write the final configuration to `main.tf`.

## Input Files

The following file is provided as input. Extract it before beginning.

=============== FILE: inputs/draft.tf ===============
terraform {
  required_providers {
    namecheap = {
      source  = "namecheap/namecheap"
      version = ">= 2.0.0"
    }
  }
}

provider "namecheap" {}

resource "namecheap_domain_records" "nexuspayments_ns" {
  domain = "nexuspayments.com"
  mode   = "OVERWRITE"

  nameservers = [
    "Nora.NS.Cloudflare.COM",
    "Rod.NS.Cloudflare.COM"
  ]

  record {
    hostname = "@"
    type     = "A"
    address  = "192.0.2.99"
  }
}

## Output Specification

Produce a single corrected file: `main.tf`
