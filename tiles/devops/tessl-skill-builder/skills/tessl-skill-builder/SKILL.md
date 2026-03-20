---
name: tessl-skill-builder
description: Generate Tessl skills from prompts with full Tessl spec compliance. Creates SKILL.md, tile.json, eval scenarios, AGENTS.md, and docs. Auto-triggers on "create a skill", "build a skill", "generate a tessl skill", or when user wants to scaffold a new agent capability.
---

# Tessl Skill Builder

Meta-skill that generates production-ready Tessl skills from prompts. Every generated tile includes SKILL.md, tile.json, eval scenarios, AGENTS.md, and optional docs — all matching Tessl spec.

## Trigger Phrases

Activate when the user says: "create a skill", "build a skill", "generate a tessl skill", "scaffold a new skill", "make a tessl tile", "I want a skill for [domain]", or any request implying creating a new agent capability tile.

## Core Process

### Step 1: Clarify

Ask the user:
- **Purpose**: What problem does this skill solve?
- **Domain**: devops, backend, security, frontend, qa?
- **Audience**: Which agent will use it? (Claude Code, Cursor, Copilot, OpenCode)
- **Tools**: Which tools must the agent use?

If ambiguous, ask ONE clarifying question before generating.

### Step 2: Generate Tile Structure

```
tiles/<domain>/<name>/
├── tile.json
├── SKILL.md
├── docs/                  (optional)
│   └── *.md
├── evals/                 (optional)
│   └── <scenario>/
│       ├── task.md
│       └── criteria.json
└── AGENTS.md
```

### Step 3: Generate Files

1. **SKILL.md** — with valid YAML frontmatter
2. **tile.json** — with correct schema
3. **evals/** — 2-3 scenarios with task.md + criteria.json
4. **AGENTS.md** — following existing patterns

### Step 4: Validate

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
<numbered workflow>

## Reference
<examples, patterns, anti-patterns>
```

### Frontmatter Fields (ALL REQUIRED)

| Field | Constraints |
|-------|-------------|
| `name` | kebab-case |
| `description` | 1-1024 chars |

---

## tile.json Template

```json
{
  "name": "steio-skills/<name>",
  "version": "0.2.0",
  "summary": "<brief>",
  "private": true,
  "skills": {
    "<name>": { "path": "SKILL.md" }
  }
}
```

### Rules

- `name` matches `steio-skills/<kebab-case>`
- `version` is valid semver
- `skills` keys match SKILL.md frontmatter `name`
- `private: true` until publishing

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

### Rules

- Minimum 2 scenarios per tile
- max_score sums to 100 per criteria.json
- Criteria names specific and actionable

---

## Companion Skills

After generating a tile, see [COMPANION_SKILLS.md](../../COMPANION_SKILLS.md) for the full development lifecycle tiles — eval-setup, eval-improve, compare-skill-model-performance, developing-tessl-skills, and tile-creator.

---

## Naming Conventions

| Element | Format | Example |
|---------|--------|---------|
| Tile dir | kebab-case | `namecheap-terraform` |
| Skill name | kebab-case | `tailscale-terraform` |
| Domain | kebab-case | `devops`, `backend` |
| Scenario | kebab-case | `basic-usage` |

---

## Mandatory Versioning

Every published tile must have a `version` field in `tile.json` following [Semver](https://semver.org/).

### Tessl Rules

- **Start at `0.1.0`** — never `0.0.1` or `1.0.0`
- **Publish at `1.0.0`** when ready for production (stable behavior, passing evals)
- **Keep `private: true`** until `1.0.0` or explicit QA
- **Increment before PR** — bump on any functional change

---

## Validators (run after generation)

Check for any of the following issues and report them before finishing:

| Artifact | Check |
|----------|-------|
| SKILL.md | Frontmatter parses as valid YAML; `name` and `description` present; no placeholder text (`<TBD>`, `<TODO>`) |
| tile.json | Valid JSON; `name` matches `steio-skills/<slug>`; `version` valid semver; `skills` keys match SKILL.md frontmatter |
| Evals | task.md has Setup, Task, Expected Behavior sections; criteria.json `type` is `weighted_checklist`; max_score sums to 100 |

---

## Error Handling

| Scenario | Response |
|----------|----------|
| Ambiguous request | Ask ONE clarifying question |
| Invalid frontmatter | Report specific YAML error with line |
| Missing domain | Default to `devops`, confirm with user |
| File exists | Warn, offer overwrite or rename |
