---
name: tessl-skill-builder
description: Generate production-ready Tessl skills from prompts with full Tessl spec compliance. Creates SKILL.md, tile.json, eval scenarios, AGENTS.md, and docs. Auto-triggers on "create a skill", "build a skill", "generate a tessl skill", or when user wants to scaffold a new agent capability tile. Integrates with anthropic-skill-creator methodology for interview, draft, and iteration workflow.
---

# Tessl Skill Builder

Generate production-ready Tessl skills from prompts. Combines **anthropic-skill-creator** methodology with **Tessl-specific** templates for: interview → draft → eval → publish.

---

## ⚠️ CRITICAL: ALWAYS CLARIFY FIRST

**BEFORE generating ANY tile, ask clarifying questions. Skipping this is the #1 cause of skill failures.**

| Request Type | Action |
|--------------|--------|
| Clear, specific request | Ask 1 question to confirm |
| Ambiguous or vague | Ask 3+ questions until clear |
| "Just generate it" | Ask: "What domain should this be in?" |

**Questions:** Purpose? Trigger phrases? Output format? Domain? Audience? Tools?

---

## Tile Structure

```
tiles/<domain>/<name>/
├── tile.json           # REQUIRED - Tile manifest
├── AGENTS.md           # REQUIRED - Project context
├── skills/
│   └── <name>/
│       └── SKILL.md    # REQUIRED - Skill instructions
├── docs/               # OPTIONAL
└── evals/              # REQUIRED - 2-3 scenarios
    └── <scenario>/
        ├── task.md
        └── criteria.json
```

---

## Core Process

### Step 1: Capture Intent

**Ask clarifying questions. See "CRITICAL" section above.**

### Step 2: Generate SKILL.md

**Mandatory frontmatter:**
```yaml
---
name: <skill-name>        # kebab-case
description: <1-1024 chars, MUST be "pushy">
---
```

**Mandatory sections:**
1. `## When to Use` — Trigger phrases and contexts
2. `## Core Process` — Numbered workflow
3. `## Reference` — Examples, patterns, anti-patterns

**Pushy description example:**
```
❌ Weak: "Generate Terraform modules for AWS."
✅ Pushy: "Generate Terraform modules for AWS. Use when user asks to 'create terraform module', 'build infrastructure as code', or mentions Terraform + AWS. Triggers on VPC, EC2, S3, RDS requests."
```

### Step 3: Generate tile.json

```json
{
  "name": "steio-skills/<name>",
  "version": "0.1.0",
  "summary": "<brief description>",
  "entrypoint": "AGENTS.md",
  "private": true,
  "skills": { "<name>": { "path": "skills/<name>/SKILL.md" } }
}
```

**Rules:**
- `name` MUST start with `steio-skills/`
- `version` MUST be `0.1.0` for new tiles (never `0.0.1` or `1.0.0`)
- `private: true` until production-ready

### Step 4: Generate AGENTS.md

AGENTS.md provides project-level context that agents load automatically.

**Template:**
```markdown
# <Project Name>

Brief description.

## Project Structure

\`\`\`
<project>/
├── src/
├── tests/
└── docs/
\`\`\`

## Key Commands

| Command | Purpose |
|---------|---------|
| `npm test` | Run tests |

## Architecture Decisions

- Decision 1: Why we made this choice
```

**Required sections:** Project overview, Directory structure, Build/test commands

### Step 5: Generate Evals

**Minimum 2 scenarios per tile.**

**task.md structure:**
```markdown
# <Scenario Name>

## Setup
<prerequisites>

## Task
<user prompt>

## Expected Behavior
<outcomes>

## Validation
<checklist>
```

**criteria.json structure:**
```json
{
  "context": "<what is being evaluated>",
  "type": "weighted_checklist",
  "checklist": [
    { "name": "<criterion>", "description": "<what>", "max_score": 20, "category": "INTENT" }
  ]
}
```

**Rules:**
- `max_score` sums to 100 per criteria.json
- Every item must have `category` (INTENT, DESIGN, MUST_NOT, MINIMALITY, REUSE, INTEGRATION, EDGE_CASE)
- Use multiple category types

### Step 6: Validate

```bash
tessl tile lint ./<tile>      # Validate structure
tessl skill review ./<tile>   # Quality review
```

**Score thresholds:** 90%+ ready | 70-89% minor fixes | <70% needs work

---

## Evaluation Workflow

### Local Evals

```bash
tessl scenario generate <tile> --count=3 --workspace=<ws>
tessl scenario download --last && mv ./evals/ <tile>/evals/
tessl eval run <tile> --workspace=<ws>
```

**Metrics:** Baseline vs With-context → Delta (+pp = skill helps)

### Description Optimization (CRITICAL for triggering)

After creating a skill, test the `description` field:

1. Create `evals/description-queries.json` with should-trigger/should-not-trigger queries
2. Run trigger eval to measure accuracy
3. Select description with >90% trigger rate, <10% false positives

### Publish to Registry

**Evals only appear in dashboard after publish.**

```bash
# After PR merged to main
tessl tile publish ./<tile> --bump patch
```

**Auto-publish:** GitHub Action publishes on merge to main (if configured with `TESSL_API_TOKEN`).

---

## Validation Checklist

**ALWAYS validate before reporting completion.**

### SKILL.md

- [ ] Frontmatter parses as valid YAML
- [ ] `name` is kebab-case
- [ ] `description` ≤ 1024 chars
- [ ] No placeholder text

### tile.json

- [ ] Valid JSON
- [ ] `name` starts with `steio-skills/`
- [ ] `version` is `0.1.0` for new tiles
- [ ] `private: true` until production-ready
- [ ] At least one of `docs`, `steering`, or `skills`

### Evals

- [ ] task.md has: Setup, Task, Expected Behavior, Validation
- [ ] criteria.json has: `context`, `type: "weighted_checklist"`, checklist with `category`
- [ ] max_score sums to 100
- [ ] Multiple category types used

### Publishing

- [ ] Increment version before PR
- [ ] Publish at `1.0.0` when stable

---

## Error Handling

| Scenario | Response |
|----------|----------|
| Ambiguous request | Ask clarifying questions |
| Missing domain | Default to `devops`, confirm |
| File exists | Warn, offer overwrite |
| Review < 70% | Suggest `tessl skill review --optimize` |
| Baseline ≈ With-context | Warn: skill adds little value |

---

## Reference

- [Configuration](../../docs/configuration.md) — tile.json fields
- [Eval Criteria](../../docs/eval-criteria.md) — Category types
- [Companion Skills](../../docs/companion-skills.md) — Related skills