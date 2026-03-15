Namecheap Terraform provider: MERGE vs OVERWRITE mode

What changes in each mode:
- MERGE: Create or update records as declared. Preserve any existing records that are not declared in Terraform. No deletions of non-declared records.
- OVERWRITE: Replace the entire DNS record set with exactly what you declare in Terraform. Deletes any existing records not present in the configuration.

When to use:
- Use MERGE for day-to-day changes when you want to avoid accidentally deleting unrelated records (e.g., existing mail, SPF/TXT, legacy entries). This is the safe default for incremental changes.
- Use OVERWRITE when you want the zone to be an exact reflection of your Terraform state (e.g., migrating all records from another system, or performing a clean reset). Be aware this can delete records you did not declare in code.

Cautions:
- OVERWRITE can cause loss of records (MX, TXT, CNAME, etc.) if they are not present in your config. Always back up or declare all required records.
- MERGE will not remove stray records; if you need cleanup, you must explicitly declare them under OVERWRITE or perform a separate cleanup plan.

Quick guidance:
- If you’re unsure, start with MERGE to observe what would be added/updated without removing anything. Switch to OVERWRITE only when you intend to prune to your declared state.
