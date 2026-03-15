Namecheap API Client IP is not whitelisted

Root cause
- The Namecheap API requires the public IP address (ClientIp) that your requests originate from to be whitelisted in your Namecheap account. If the IP making the Terraform provider requests is not in the whitelist, Namecheap will reject the API call with "Client IP is not whitelisted" even if your API key is correct.

What to do
1) Determine the public IP address used by the machine or CI runner that runs terraform apply
- On a local machine: curl -s https://ifconfig.me
- Or: curl -s https://ipinfo.io/ip
- Result will be an IPv4 like 1.2.3.4

2) Whitelist that IP in Namecheap
- Log in to Namecheap account.
- Go to API Access (or Profile > API Access) → IP Whitelist (Allowed IP Addresses).
- Add the IPv4 address you obtained in step 1. If you run from multiple networks or CI, add all known outbound IPs or ranges.
- Save changes. It may take a moment to propagate.

3) if you run from CI or behind a VPN/Proxy
- Ensure the CI runner (or VPN) uses a fixed/public outbound IP and whitelist that IP as well.
- If you use a dynamic IP, you must update the whitelist whenever the IP changes, or use a fixed NAT/egress IP.

4) Align provider configuration with the whitelisted IP
- Some Namecheap Terraform providers pass ClientIp in requests. If your provider requires it, set a client_ip (or equivalent) field to the same IP you whitelisted.
- Double-check that ApiUser, ApiKey, and UserName correspond to the same account whose IP whitelist you updated.

5) Validate
- Re-run terraform apply.
- If you want to test quickly, call the Namecheap API directly with your credentials and the same ClientIp to confirm the API accepts the request.
  Example (replace placeholders):
  curl -G https://api.namecheap.com/xml.response \
    -d ApiUser="your_api_user" \
    -d ApiKey="your_api_key" \
    -d UserName="your_username" \
    -d Command="namecheap.domains.getList" \
    -d ClientIp="1.2.3.4"

Notes
- If you recently updated the whitelist, allow a couple minutes for propagation before testing again.
- Ensure IPv4 address is whitelisted; IPv6 may be rejected by Namecheap API.
- If you still see the error after whitelisting, verify there are no conflicting firewall rules or corporate proxies changing the outgoing IP.

EXPECTED OUTPUT
- terraform apply completes successfully without the "Client IP is not whitelisted" error.
- The Namecheap API calls return a valid response (no security/IP restriction errors).

Success criteria / verification
- 1) The API calls succeed (HTTP 200) and return expected data.
- 2) terraform apply finishes with no Namecheap API IP-related errors.
