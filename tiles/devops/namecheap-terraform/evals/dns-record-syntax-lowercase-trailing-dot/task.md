# DNS Setup for SaaS Product Launch

## Problem/Feature Description

Acme Corp is launching their new project management SaaS product, "TaskFlow," hosted on their domain `taskflow.io`. The infrastructure team needs to set up comprehensive DNS records using Terraform so that the configuration is reproducible and version-controlled. The domain is fresh — no existing DNS records to worry about, and the team has full control.

The product requires several DNS components: the apex domain should point to their CDN distribution (a hostname, not an IP), the `www` subdomain should redirect visitors to the apex, and an `api` subdomain must point to their backend server at IP `203.0.113.50`. Email is handled by their own mail servers at `mail1.taskflow.io` (priority 10) and `mail2.taskflow.io` (priority 20), and the team wants proper SPF configuration to authorize those mail servers.

Write a complete Terraform configuration file (`main.tf`) for the `taskflow.io` domain. The configuration should include: the provider and required_providers block, and a resource that manages all DNS records. The CDN hostname for the apex is `cdn-endpoint.provider.net`. Set shorter TTLs (300 seconds) on the records that may need to change frequently (A, AAAA, ALIAS), and leave others at defaults.

## Output Specification

Produce a single file: `main.tf` containing the complete Terraform configuration.
