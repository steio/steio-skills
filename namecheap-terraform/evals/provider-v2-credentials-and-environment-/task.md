# CI/CD-Ready Namecheap Terraform Provider Configuration

## Problem/Feature Description

Meridian Labs has been using an older version of the Namecheap Terraform provider (v1.x) to manage DNS for their portfolio of domains. As part of a security audit, the team discovered that API credentials were hardcoded in several `.tf` files committed to their git repository. They need to migrate to the v2.x provider and adopt a credential management approach that is safe to commit to version control.

The team also wants to add a sandbox testing setup so engineers can validate their DNS configurations before applying changes to production. They've received Namecheap sandbox account credentials (separate from production) and want a configuration file they can use during development.

Write two Terraform configuration files:
1. `production.tf` — a provider + resource configuration for production use with the domain `meridian-labs.com`, with a single A record for the apex pointing to `198.51.100.42`. The provider block should be safe to commit (no secrets).
2. `sandbox.tf` — a provider + resource configuration using the sandbox environment for the same domain structure, suitable for testing. The provider block should reference sandbox mode.

Also create `env_setup.sh` — a shell script with the `export` statements for all required environment variables (use placeholder values like `YOUR_USERNAME`, `YOUR_API_KEY`, etc.).

## Output Specification

Produce three files:
- `production.tf`
- `sandbox.tf`
- `env_setup.sh`
