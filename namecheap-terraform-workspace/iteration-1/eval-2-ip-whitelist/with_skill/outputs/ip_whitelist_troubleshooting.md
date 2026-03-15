Namecheap Terraform - IP Whitelist Troubleshooting Guide

Context: Terraform apply fails with "Client IP is not whitelisted" when using the Namecheap provider. The API key may be correct, but the client IP making the API request is not allowed by the Namecheap account's API Access whitelist.

What this means: Namecheap only accepts API requests from IP addresses that have been whitelisted in your account. If Terraform is run from a different IP (e.g., a CI runner, VPN, or a dynamic home IP), the request will be rejected with this error.

Root causes to check:
- API Access is not enabled for your Namecheap account or is not properly configured.
- The IP address used by your Terraform run is not whitelisted in the Namecheap account.
- The provider configuration uses a client_ip that does not match the whitelisted IP (or environment variables do not reflect the whitelisted IP).
- Running from CI or ephemeral environments where IPs change frequently.

Recommended fixes (in order):
1) Verify API access is enabled in the Namecheap account and that you're using the correct API credentials.
   - Path: Profile → Tools → Namecheap API Access → Enable
   - Copy the API key shown after enabling (or re-create as needed).
2) Determine the exact IP address used by the machine running Terraform.
   - Run on the machine: curl ifconfig.me
   - If behind NAT or VPN, determine the outbound IP that Namecheap sees.
   - If using CI, check the CI runner's outbound IP (many CI providers offer a static outbound IP or pools).
3) Whitelist the IP in Namecheap.
   - Path: Profile → Tools → API Access → Whitelisted IPs → Add your IP
   - If using multiple IPs (e.g., multiple CI runners or developer machines), add each one.
4) Align Terraform provider configuration with the whitelisted IP.
   - Option A: Set client_ip in the provider to the whitelisted IP address.
   - Option B: Use environment variables to supply the values, including NAMECHEAP_CLIENT_IP equal to the whitelisted IP.
     Example: export NAMECHEAP_CLIENT_IP="203.0.113.45"
   - Terraform config example:
     provider "namecheap" {
       user_name   = var.nc_user
       api_user    = var.nc_api_user
       api_key     = var.nc_api_key
       client_ip   = var.nc_client_ip
       use_sandbox = false
     }
5) Re-run Terraform.
   - terraform init -upgrade
   - terraform apply
6) If the error persists after whitelisting and aligning IPs, verify other credentials exist,
   and confirm you are not pointing to a sandbox environment unintentionally.

Tips for troubleshooting in CI/CD:
- If your CI runner uses a dynamic IP, use a VPN or a fixed NAT gateway with a static IP, and whitelist that IP.
- For GitHub Actions, consider using a self-hosted runner with a static IP or request a pool of static IPs for the runners and whitelist them.
- Check that the NAMECHEAP_CLIENT_IP environment variable is exported in the CI job environment.

Quick verification commands:
- Determine outbound IP (local):
  curl -s ifconfig.me
- Whitelist IP in Namecheap UI (one-time):
  Profile → Tools → API Access → Whitelisted IPs → Add
- Validate env vars (local or CI):
  echo $NAMECHEAP_CLIENT_IP
- Dry-run: print provider config values in Terraform (avoid exposing secrets in logs):
  terraform plan -out=plan.out

References:
- Namecheap API whitelisting guidance in the skill: Troubleshooting -> Client IP is not whitelisted
- Provider reference and examples in the Namecheap Terraform SKILL
