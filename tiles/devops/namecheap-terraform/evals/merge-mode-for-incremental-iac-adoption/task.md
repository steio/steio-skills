# Adding Staging Environment DNS Without Disrupting Production

## Problem/Feature Description

Bright Horizons Digital is a mid-sized agency that has been manually managing DNS records for their client's domain `brighthorizons.agency` directly in the Namecheap dashboard for years. The domain currently has a mix of records: an A record for the apex pointing to production servers, several CNAME records for marketing subdomains, MX records for their Microsoft 365 email, and various TXT records for third-party service verifications.

The DevOps team has recently started adopting Terraform and wants to begin version-controlling DNS changes — but they're nervous about accidentally wiping out the carefully configured production records that are not yet documented anywhere. Their first goal is modest: manage only the DNS records for a new staging environment they're spinning up. Specifically, they need to add:

- An A record for `staging.brighthorizons.agency` pointing to `10.20.30.40`
- A CNAME for `api-staging.brighthorizons.agency` pointing to `staging-api.internal.brighthorizons.agency`
- A TXT record at `staging.brighthorizons.agency` with value `v=verify staging-env-001` for a third-party monitoring tool

Write a Terraform configuration (`main.tf`) that manages only these three new staging records, preserving all the existing records the team hasn't touched. Also include the shell command the team should run to bring any existing records under Terraform state management safely.

## Output Specification

Produce two files:
- `main.tf` — the Terraform configuration
- `import_commands.sh` — shell script containing the Terraform import command(s) needed
