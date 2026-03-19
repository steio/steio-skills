---
name: tessl-skill-builder
description: Generate Tessl skills from prompts with full Tessl spec compliance. Creates SKILL.md, tile.json, eval scenarios, AGENTS.md, and docs. Auto-triggers on "create a skill", "build a skill", "generate a tessl skill".
---

# Tessl Skill Builder

Meta-skill that generates production-ready Tessl skills with full spec compliance.

## Trigger Phrases

- "create a skill"
- "build a skill"
- "generate a tessl skill"
- "scaffold a new skill"
- "I want a skill for [domain]"

## Core Process

### Step 1: Clarify

Ask the user:
- **Purpose**: What problem does this skill solve?
- **Domain**: devops, backend, security, frontend, qa?
- **Tools**: Which tools must the agent use?

If ambiguous, ask ONE clarifying question before generating.

### Step 2: Generate Files

Create:
- `SKILL.md` — with valid YAML frontmatter
- `tile.json` — with correct schema
- `evals/` — 2-3 scenarios with task.md + criteria.json
- `AGENTS.md` — following existing patterns

### Step 3: Validate

- SKILL.md frontmatter valid YAML
- tile.json valid JSON, name matches `steio-skills/<slug>`
- Eval criteria.json type is `weighted_checklist`, max_score sums to 100

---

## SKILL.md Template

```yaml
---
name: <skill-name>
description: <1-1024 chars>
---

# <Title>

## When to Use
<trigger phrases>

## Core Process
<workflow>

## Reference
<examples, patterns, anti-patterns>
```

---

## tile.json Template

```json
{
  "name": "steio-skills/<skill-name>",
  "version": "0.1.0",
  "summary": "<brief description>",
  "private": true,
  "skills": {
    "<skill-name>": { "path": "SKILL.md" }
  }
}
```

---

## Eval Template

**task.md:**
```markdown
# <Scenario>
## Setup
## Task
## Expected Behavior
## Validation
```

**criteria.json:**
```json
{
  "context": "<description>",
  "type": "weighted_checklist",
  "checklist": [
    { "name": "<criterion>", "description": "<what>", "max_score": <n> }
  ]
}
```

---

## Naming Conventions

| Element | Format |
|---------|--------|
| Tile dir | kebab-case |
| Skill name | kebab-case |
| Domain | devops, backend, security, frontend, qa |

---

## Validators

### SKILL.md
- Frontmatter valid YAML
- `name` and `description` present
- No placeholder text

### tile.json
- Valid JSON
- `name` matches `steio-skills/<slug>`
- `version` valid semver

### Eval
- task.md has Setup, Task, Expected Behavior
- criteria.json has `type: "weighted_checklist"`
- max_score sums to 100