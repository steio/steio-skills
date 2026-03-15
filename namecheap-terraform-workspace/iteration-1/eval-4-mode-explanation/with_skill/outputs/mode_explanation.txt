Difference between MERGE and OVERWRITE mode in the Namecheap Terraform provider

What each mode does:
- MERGE (default): Update and add only the DNS records you declare in your Terraform configuration. Existing manual records that are not mentioned in config are left intact. This mode is safe for incremental changes and ongoing management of a domain's DNS without accidentally removing records you added outside Terraform.
- OVERWRITE: Replaces the domain's DNS records with exactly the ones you declare in your Terraform config. All manually created or unmanaged records are removed, and only the records specified in the config are kept. This is destructive and should be used when you want to synchronize the domain's records to a known, Terraform-defined state.

When to use MERGE:
- You want to add or update a few records without touching other existing records (MX, A, CNAME, etc.) that may already exist.
- You are doing incremental updates or ongoing DNS management where records may be added outside Terraform over time.
- You want Terraform to coexist with existing manually-managed records without deleting them.

When to use OVERWRITE:
- You want to reset the domain's DNS configuration to exactly match what Terraform declares, removing any extra or stray records.
- You are migrating a domain to Terraform management and want a clean, Terraform-driven state.
- You need to ensure that no unmanaged records exist for the domain, for example in strict test or compliance scenarios.

Notes and caveats:
- The OVERWRITE mode is destructive. Any records not declared in the Terraform config will be removed on apply.
- The resource argument set for OVERWRITE typically includes domain, mode = "OVERWRITE", and either record blocks or a nameservers setting to define the exact desired state.
- The nameservers configuration may conflict with record definitions; the docs commonly show how OVERWRITE interacts with both records and nameservers. If you specify both records and nameservers, ensure you intend to set them together.
- See the official docs for the Domain Records resource for exact syntax and examples.

Reference (source): namecheap_domain_records resource docs
Summary: MERGE updates/adds only defined records; OVERWRITE replaces all domain records with those you declare.
