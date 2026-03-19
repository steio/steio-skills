---
name: tessl-skill-builder
description: Generate Tessl skills from prompts with full Tessl spec compliance. Creates SKILL.md, tile.json, eval scenarios, AGENTS.md, and docs. Auto-triggers on "create a skill", "build a skill", "generate a tessl skill", or when user wants to scaffold a new agent capability.
---

# Tessl Skill Builder

Meta-skill that generates production-ready Tessl skills from prompts. Every generated tile includes SKILL.md, tile.json, eval scenarios, AGENTS.md, and optional docs — all matching Tessl spec.

## Trigger Phrases

Activate when the user says:
- "create a skill"
- "build a skill"
- "generate a tessl skill"
- "scaffold a new skill"
- "make a tessl tile"
- "I want a skill for [domain]"
- Any request implying creating a new agent capability tile

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

After generating a tile, the full development lifecycle uses these Tessl tiles. Install and invoke as needed.

### For Evals: `tessl-labs/eval-setup`

**Install:** `tessl install tessl-labs/eval-setup`
**Triggers:** "set up evals", "generate eval scenarios", "benchmark my tile"

Full pipeline: commit selection → scenario generation → run baseline + with-context evals → compare results.

### For Improving Evals: `tessl-labs/eval-improve`

**Install:** `tessl install tessl-labs/eval-improve`
**Triggers:** "improve my eval scores", "fix failing criteria", "analyze eval results"

Full cycle: classify scores into buckets (working/gap/redundant/regression) → diagnose root causes → apply fixes → re-run → verify.

### For Multi-Model Comparison: `tessl-labs/compare-skill-model-performance`

**Install:** `tessl install tessl-labs/compare-skill-model-performance`
**Triggers:** "compare models", "test across agents", "validate for different models"

Runs evals across multiple models (claude-haiku, claude-sonnet, claude-opus) and compares results.

### For Full Lifecycle: `nagaakihoshi/developing-tessl-skills`

**Install:** `tessl install nagaakihoshi/developing-tessl-skills`
**Triggers:** "prepare for PR", "publish my skill", "full development workflow"

Full lifecycle: `tessl skill review --optimize` → increment version → `tessl skill lint` → stage for PR.

### For Tile Creation: `tessl-labs/tile-creator`

**Install:** `tessl install tessl-labs/tile-creator`
**Triggers:** "create tile from existing content", "convert repo to tile"

Alternative creation method using MCP tool (`mcp__tessl__new_tile`) or CLI. Three types: docs (facts), skills (workflows), rules (constraints).

---

## Development Lifecycle

```
generate → eval-setup → eval-improve → compare-models → developing-tessl-skills
   │            │            │              │                │
   ▼            ▼            ▼              ▼                ▼
 create     scenarios    fix scores      cross-model       lint + publish
 files       + run        + re-run         validation       + version
```

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

**Every published tile must have a `version` field in `tile.json` following [Semver](https://semver.org/).**

### When to Increment

| Change type | Version | Example |
|-------------|---------|---------|
| Bugfix, refactor with no behavior change | `0.1.x` | `0.1.0` → `0.1.1` |
| New functionality (no breaking change) | `0.x.0` | `0.1.0` → `0.2.0` |
| Breaking change (behavior or API change) | `x.0.0` | `0.5.0` → `1.0.0` |
| First public release | `1.0.0` | — |

### Rules

- **Start at `0.1.0`** — `0.x.y` signals the API/behavior may still change
- **Publish at `1.0.0`** when ready for production use (stable behavior, passing evals)
- **Keep `private: true`** until `1.0.0` or explicit QA sign-off
- **Increment before PR** — never commit without a version bump when there's a functional change
- **Changelog in PR** — describe what changed and why the version bumped

### Commit Message Template with Version Bump

```
feat(tile): add <name> skill for <domain>

version: 0.1.0 → 0.2.0 (new functionality)

- Added SKILL.md with <N> trigger phrases
- Added <M> eval scenarios
- Added AGENTS.md

Closes #<PR_NUMBER>
```

### Applying During Tile Generation

When generating a new tile: always start at `0.1.0` (not `0.0.1`, not `1.0.0`).
When modifying an existing tile: check for functional changes before incrementing.

---

## Validators (run after generation)

### SKILL.md
- Frontmatter parses as valid YAML
- `name` and `description` present
- No placeholder text (`<TBD>`, `<TODO>`)

### tile.json
- Valid JSON
- `name` matches `steio-skills/<slug>`
- `version` valid semver
- `skills` keys match SKILL.md frontmatter

### Eval
- task.md has Setup, Task, Expected Behavior
- criteria.json has `type: "weighted_checklist"`
- max_score sums to 100

---

## Error Handling

| Scenario | Response |
|----------|----------|
| Ambiguous request | Ask ONE clarifying question |
| Invalid frontmatter | Report specific YAML error with line |
| Missing domain | Default to `devops`, confirm with user |
| File exists | Warn, offer overwrite or rename |
