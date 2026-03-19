# Generate From Prompt

Skill generates a valid Tessl tile from a clear prompt.

## Setup

- Clean workspace
- Tessl CLI available

## Task

User: "create a skill for managing PostgreSQL connection pools"

Agent generates complete tile with SKILL.md, tile.json, evals, AGENTS.md.

## Expected Behavior

- Asks clarification if needed
- Generates valid SKILL.md with frontmatter
- Generates valid tile.json
- Creates 2+ eval scenarios

## Validation

1. SKILL.md frontmatter valid YAML
2. tile.json valid JSON with `name: "steio-skills/postgres-connection-pool"`
3. Each eval has task.md + criteria.json