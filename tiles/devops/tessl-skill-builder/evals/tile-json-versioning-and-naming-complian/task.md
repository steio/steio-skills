# SSL Certificate Renewal Skill

## Problem/Feature Description

Your infrastructure team manages hundreds of services across multiple environments. SSL certificates are expiring at unpredictable intervals, causing outages because no one catches renewals in time. The team wants a reusable agent skill that can automate and guide SSL certificate renewal workflows — checking expiry, triggering renewals, and confirming deployment.

A junior engineer has been asked to create a Tessl skill tile for this automation capability. The tile needs to be ready for internal use but is still in early development, not yet approved for production.

## Output Specification

Create a complete Tessl skill tile for an SSL certificate renewal assistant. The tile should be placed under a logical domain directory. You must produce at minimum:

- `tile.json` with all required fields correctly filled in
- `SKILL.md` with YAML frontmatter and skill content
- At least 2 eval scenarios under `evals/`, each with a `task.md` and `criteria.json`
- `AGENTS.md`

Write all files to a subfolder in your working directory. Do not leave placeholder values in any generated file.
