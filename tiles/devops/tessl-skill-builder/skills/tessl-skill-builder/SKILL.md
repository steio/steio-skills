---
name: tessl-skill-builder
description: Generate production-ready Tessl skills from prompts with full Tessl spec compliance. Creates SKILL.md, tile.json, eval scenarios, AGENTS.md, and docs. Auto-triggers on "create a skill", "build a skill", "generate a tessl skill", or when user wants to scaffold a new agent capability tile. Integrates with skill-creator methodology for interview, draft, and iteration workflow.
---

# Tessl Skill Builder

Meta-skill that generates production-ready Tessl skills from prompts. Combines **skill-creator** methodology with **Tessl-specific** templates for complete workflow: interview → draft → eval → publish.

## Architecture

```
skill-creator methodology     tessl-skill-builder specifics
─────────────────────────     ─────────────────────────────
Interview & capture intent  →  Tessl namespace rules
Draft SKILL.md              →  tile.json + eval templates
Test & iterate              →  tessl eval run
Description optimization    →  GitHub Actions publish
```

**Uses `skill-creator` for:** interview methodology, iteration workflow, description optimization.
**Adds Tessl-specifics:** tile.json schema, eval format (category/context), registry publishing.

## Trigger Phrases

Activate when the user says: "create a skill", "build a skill", "generate a tessl skill", "scaffold a new skill", "make a tessl tile", "I want a skill for [domain]", or any request implying creating a new agent capability tile.

## Core Process

### Step 1: Capture Intent (MANDATORY)

**ALWAYS ask clarifying questions before generating.** Use skill-creator interview methodology:

1. **Purpose**: What problem does this skill solve?
2. **When**: What user phrases/contexts should trigger it?
3. **Output**: What's the expected output format?
4. **Domain**: devops, backend, security, frontend, qa?
5. **Audience**: Which agent will use it? (Claude Code, Cursor, Copilot, OpenCode)
6. **Tools**: Which tools must the agent use?
7. **Test cases**: Should we set up evals? (Skills with objectively verifiable outputs benefit from test cases)

If the request is clear, ask at least ONE question to confirm understanding.
If ambiguous, ask multiple questions until unambiguous.

**DO NOT skip this step.** Generation without clarification produces generic, low-quality tiles.

### Step 2: Generate Tile Structure

```
tiles/<domain>/<name>/
├── tile.json
├── SKILL.md
├── docs/                  (optional)
│   └── *.md
├── evals/
│   └── <scenario>/
│       ├── task.md
│       ├── criteria.json
│       └── scenario.json  (for codebase evals)
└── AGENTS.md
```

### Step 3: Generate Files

1. **SKILL.md** — with valid YAML frontmatter
2. **tile.json** — with correct schema
3. **evals/** — 2-3 scenarios with task.md + criteria.json + scenario.json
4. **AGENTS.md** — following existing patterns

### Step 4: Test & Iterate

Use skill-creator iteration methodology:

1. **Create test prompts** — 2-3 realistic user prompts
2. **Run baseline** — test without skill
3. **Run with skill** — test with skill loaded
4. **Compare results** — measure improvement
5. **Gather feedback** — user reviews outputs
6. **Improve skill** — iterate until satisfied

```bash
tessl tile lint ./<tile>      # Validate structure
tessl skill review ./<tile>   # Check best practices
tessl eval run ./<tile>       # Measure effectiveness
```

### Step 5: Optimize Description

The `description` field in frontmatter is the **primary triggering mechanism**. After creating a skill:

1. Generate 20 trigger eval queries (mix of should-trigger and should-not-trigger)
2. Run description optimization loop
3. Apply best description based on test scores

**Tip:** Make descriptions "pushy" to combat under-triggering. Include both what the skill does AND specific contexts for when to use it.

### Step 6: Publish

**GitHub Action auto-publishes on merge to main.** See [Publishing Workflow](#publishing-workflow) for details.

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

## tile.json

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

### Critical Rules

- **name MUST start with `steio-skills/`** — e.g., `"steio-skills/redis-cache-monitor"`
- **version MUST be `0.1.0`** for new tiles — never `0.0.1` or `1.0.0`
- **private MUST be `true`** for unpublished/pre-production tiles
- **SKILL.md frontmatter name MUST be kebab-case** — e.g., `name: redis-cache-monitor`

For complete field reference, see [Configuration Files](../../docs/configuration.md).

**Validation:** At least one of `docs`, `steering`, or `skills` required.

---

## Eval Template

**task.md:**
```markdown
# <Scenario Name>

## Setup

<Describe prerequisites: environment, files, tools needed>

## Task

<User prompt or scenario description>

## Expected Behavior

<List specific expected outcomes>

## Validation

<Checklist of what to verify>
```

**criteria.json:**
```json
{
  "context": "<description of what is being evaluated>",
  "type": "weighted_checklist",
  "checklist": [
    { "name": "<criterion>", "description": "<what>", "max_score": <n>, "category": "INTENT" },
    { "name": "<criterion>", "description": "<what>", "max_score": <n>, "category": "DESIGN" },
    { "name": "<criterion>", "description": "<what>", "max_score": <n>, "category": "MUST_NOT" }
  ]
}
```

**Required fields in criteria.json:**
- `context`: String describing what is being evaluated
- `type`: Must be `"weighted_checklist"`
- `checklist`: Array of objects, each with:
  - `name`: Criterion identifier (kebab-case)
  - `description`: What is being checked
  - `max_score`: Points for this criterion
  - `category`: One of `INTENT`, `DESIGN`, `MUST_NOT`, `MINIMALITY`, `REUSE`, `INTEGRATION`, `EDGE_CASE`

**Required sections in task.md:**
- `## Setup` — Prerequisites
- `## Task` — What the agent should do
- `## Expected Behavior` — Expected outcomes
- `## Validation` — How to verify success

**scenario.json** (required for registry evals):
```json
{
  "type": "coding",
  "fixture": {
    "type": "commit",
    "repoUrl": "<repo-url>",
    "ref": "<commit-hash>",
    "exclude": ["*.md", ".tessl/"]
  }
}
```

**When scenario.json is needed:**
- **Local evals** (`tessl eval run ./<tile>`): Only task.md + criteria.json required
- **Registry evals** (after publish): scenario.json required for each scenario
- **Auto-generation**: `tessl tile publish` generates scenario.json automatically if missing

### Rules

- **Minimum 2 scenarios** per tile
- **max_score sums to 100** per criteria.json
- **Every checklist item must have category** — see [Eval Criteria Categories](../../docs/eval-criteria.md)
- **Use multiple category types** — not all INTENT
- **Criteria names specific and actionable**
- **context field required** in every criteria.json

---

## Evaluation Lifecycle

After generating a tile, guide the user through evaluation:

### Phase 1: Skill Review

```bash
tessl skill lint ./<tile>           # Validate structure
tessl skill review ./<tile>         # Quality review
tessl skill review --optimize ./<tile>  # Auto-fix issues
```

**Score thresholds:** 90%+ = ready | 70-89% = minor fixes | <70% = needs work

### Phase 2: Scenario-Based Evals

Test if agents perform better WITH the skill:

```bash
tessl scenario generate <tile> --count=3 --workspace=<ws>
tessl scenario download --last && mv ./evals/ <tile>/evals/
tessl eval run <tile> --workspace=<ws>
```

**Metrics:** Baseline vs With-context → Delta (+pp = skill helps)

### Phase 3: Multi-Model Comparison

```bash
tessl eval run <tile> --agent=claude:claude-haiku-4-5
tessl eval run <tile> --agent=claude:claude-sonnet-4-6
tessl eval run <tile> --agent=claude:claude-opus-4-6
```

### Phase 4: Documentation Eval

Tiles with `describes` field are auto-evaluated on publish for API correctness.

### Phase 5: Publish to Registry

**CRITICAL: Evals only appear in dashboard after publish.**

```bash
# After PR merged to main
tessl tile publish ./<tile> --bump patch
```

**Why publish is required:**
- Local evals (`tessl eval run`) only save results locally
- Dashboard shows evals from **registry only**
- GitHub Actions auto-publishes on merge (if configured)

**Auto-publish setup:**
1. Add `TESSL_API_TOKEN` to repo secrets
2. Workflow `.github/workflows/publish-tiles.yml` handles:
   - Detect changed tiles
   - Bump version if needed
   - Publish to registry
   - Run evals

**Manual publish checklist:**
- [ ] PR merged to main
- [ ] `tessl tile publish ./<tile> --bump patch`
- [ ] Verify at `tessl.io/registry/<workspace>/<tile>`

### Publish Checklist

| Condition | Action |
|-----------|--------|
| Review < 70% | Fix first |
| Review 70-89% | Consider `--optimize` |
| Baseline ≈ With-context | Warn: skill adds little value |
| **After merge** | **Publish to registry** |

---

## Companion Skills

After generating a tile, see [Companion Skills](../../docs/companion-skills.md) for the full development lifecycle tiles — eval-setup, eval-improve, compare-skill-model-performance, developing-tessl-skills, and tile-creator.

---

## Naming Conventions

| Element | Format | Example |
|---------|--------|---------|
| Tile dir | kebab-case | `namecheap-terraform` |
| Skill name | kebab-case | `tailscale-terraform` |
| Domain | kebab-case | `devops`, `backend` |
| Scenario | kebab-case | `basic-usage` |

---

## Validation Checklist

**ALWAYS validate before reporting completion.** Run `tessl tile lint <path>` to validate automatically.

### SKILL.md

- Frontmatter parses as valid YAML
- `name` is kebab-case
- `description` ≤ 1024 chars
- No placeholder text (`<TBD>`, `<TODO>`)

### tile.json

- Valid JSON
- `name` starts with `steio-skills/`
- `version` is `0.1.0` (never `0.0.1` or `1.0.0`)
- `private: true` until production-ready
- At least one of `docs`, `steering`, or `skills` present

### Evals

- task.md has: Setup, Task, Expected Behavior, Validation sections
- criteria.json has: `context`, `type: "weighted_checklist"`, checklist items with `category`
- max_score sums to 100 per criteria.json
- Multiple category types used (not all INTENT)

### Publishing Rules

- Increment version before PR
- Publish at `1.0.0` when stable (passing evals, explicit QA)

---

## Error Handling

| Scenario | Response |
|----------|----------|
| Ambiguous request | Ask clarifying questions until unambiguous |
| Invalid frontmatter | Report specific YAML error with line |
| Missing domain | Default to `devops`, confirm with user |
| File exists | Warn, offer overwrite or rename |
| Review score < 70% | Suggest `tessl skill review --optimize` |
| Baseline ≈ With-context | Warn skill may add little value |
| Eval run failed | Suggest `tessl eval retry <id>` |

---

## Publishing Workflow

### GitHub Action (Automatic)

**Tiles are auto-published when merged to main.** No manual action needed.

The workflow:
1. PR merged to `main`
2. GitHub Action detects `tiles/**` changes
3. Runs `tessl tile lint` + `tessl skill review`
4. Publishes to Tessl Registry
5. Registry auto-runs evals (generates scenario.json if missing)
6. Dashboard shows impact after eval completes

### Manual Publish (if needed)

```bash
tessl tile publish ./<tile> --bump patch
```

### Evals in Registry

| Eval Type | Files Needed | Use Case |
|-----------|--------------|----------|
| Local eval | task.md + criteria.json | Development testing |
| Registry eval | + scenario.json | Published tile evaluation |

**Note:** `tessl tile publish` auto-generates scenario.json if missing.

---

## Reference

- [Official Tessl Documentation](../../docs/) — creating-skills, creating-tiles, configuration, evaluate-skill-quality, eval-criteria, glossary, llms.txt
- [Companion Skills](../../docs/companion-skills.md) — eval-setup, eval-improve, compare-skill-model-performance, developing-tessl-skills, tile-creator
