#!/usr/bin/env python3
"""
Generate a basic Terraform configuration for Namecheap DNS management.

Usage:
    python generate_config.py --domain example.com --ip 192.0.2.1 [--output main.tf]
"""

import argparse
from pathlib import Path


TEMPLATE = """terraform {{
  required_providers {{
    namecheap = {{
      source  = "namecheap/namecheap"
      version = ">= 2.0.0"
    }}
  }}
}}

provider "namecheap" {{
  # Use environment variables for credentials:
  # NAMECHEAP_USER_NAME, NAMECHEAP_API_USER, NAMECHEAP_API_KEY, NAMECHEAP_CLIENT_IP
}}

resource "namecheap_domain_records" "{resource_name}" {{
  domain = "{domain}"
  mode   = "OVERWRITE"

  record {{
    hostname = "@"
    type     = "A"
    address  = "{ip}"
    ttl      = 300
  }}

  record {{
    hostname = "www"
    type     = "CNAME"
    address  = "{domain}."
    ttl      = 3600
  }}
}}
"""


def main():
    parser = argparse.ArgumentParser(
        description="Generate Terraform configuration for Namecheap DNS"
    )
    parser.add_argument(
        "--domain", required=True, help="Domain name (e.g., example.com)"
    )
    parser.add_argument("--ip", required=True, help="IP address for apex A record")
    parser.add_argument("--output", "-o", default="main.tf", help="Output file path")
    parser.add_argument(
        "--mode",
        default="OVERWRITE",
        choices=["MERGE", "OVERWRITE"],
        help="Record mode (default: OVERWRITE)",
    )

    args = parser.parse_args()

    resource_name = args.domain.replace(".", "-").replace("_", "-").lower()
    config = TEMPLATE.format(
        domain=args.domain, ip=args.ip, resource_name=resource_name
    )

    output_path = Path(args.output)
    output_path.write_text(config)

    print(f"Generated Terraform configuration: {output_path}")
    print(f"\nNext steps:")
    print(f"  1. Set environment variables:")
    print(f"     export NAMECHEAP_USER_NAME='your_username'")
    print(f"     export NAMECHEAP_API_USER='your_username'")
    print(f"     export NAMECHEAP_API_KEY='your_api_key'")
    print(f"     export NAMECHEAP_CLIENT_IP='your_ip'")
    print(f"  2. Run: terraform init")
    print(f"  3. Run: terraform plan")
    print(f"  4. Run: terraform apply")


if __name__ == "__main__":
    main()
