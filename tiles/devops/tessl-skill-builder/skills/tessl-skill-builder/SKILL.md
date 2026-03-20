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
3. **evals/** — 2-3 scenarios with task.md + criteria.json
4. **AGENTS.md** — following existing patterns

### Step 4: Validate

- SKILL.md frontmatter valid YAML
- tile.json valid JSON, name matches `steio-skills/<slug>`
- Eval criteria.json type is `weighted_checklist`, max_score sums to 100

### Step 5: Evaluate (Recommended)

Run skill review and scenario-based evals before publishing:
1. `tessl skill review ./<tile>` — check best practices
2. `tessl skill review --optimize ./<tile>` — auto-fix issues
3. `tessl scenario generate <tile> --count=3` — create test scenarios
4. `tessl eval run <tile>` — measure skill effectiveness

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

| Field | Required | Description |
|-------|----------|-------------|
| `name` | ✓ | `workspace/tile-name` format |
| `version` | ✓ | Semver (start `0.1.0`) |
| `summary` | ✓ | Brief description |
| `entrypoint` | | Registry UI first file (default: `index.md`) |
| `private` | | Visibility (default: `true`) |
| `docs` | | Docs entrypoint path |
| `describes` | | PURL (requires `docs`) |
| `steering` | | Rules object |
| `skills` | | Skills object |

**Validation:** At least one of `docs`, `steering`, or `skills` required.

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
    { "name": "<criterion>", "description": "<what>", "max_score": <n>, "category": "INTENT" }
  ]
}
```

**scenario.json** (for codebase evals):
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

### Rules

- Minimum 2 scenarios per tile
- max_score sums to 100 per criteria.json
- Criteria names specific and actionable

### Checklist Categories

| Category | Purpose |
|----------|---------|
| `INTENT` | Core feature/behavior the change introduces |
| `DESIGN` | Architectural or structural choices |
| `MUST_NOT` | Things the solution should avoid |
| `MINIMALITY` | Appropriate scope — no overreach |
| `REUSE` | Leveraging existing patterns |
| `INTEGRATION` | How solution connects with existing code |
| `EDGE_CASE` | Boundary conditions handled correctly |

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

### Publish Checklist

| Condition | Action |
|-----------|--------|
| Review < 70% | Fix first |
| Review 70-89% | Consider `--optimize` |
| Baseline ≈ With-context | Warn: skill adds little value |

---

## .tileignore (optional)

Exclude files from tile validation and packing. Place in tile root (same level as `tile.json`).

**Default ignored files** (no .tileignore needed):
- `AGENTS.md`, `CLAUDE.md`, `GEMINI.md`

**Example `.tileignore`:**
```gitignore
# Development notes
notes.md
TODO.md

# Draft files
*.draft.md
```

**Rules:**
- Links to ignored files cause validation errors
- Manifest entrypoints (`docs`, `rules`, `skills`) cannot be ignored

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
| tile.json | Valid JSON; `name` in `workspace/tile-name` format; `version` valid semver (start `0.1.0`); at least one of `docs`/`steering`/`skills` present; if `describes` set then `docs` required |
| Evals | task.md has Setup, Task, Expected Behavior sections; criteria.json `type` is `weighted_checklist`; max_score sums to 100; categories valid (INTENT/DESIGN/MUST_NOT/MINIMALITY/REUSE/INTEGRATION/EDGE_CASE) |
| Review | `tessl skill review` passes with ≥70% score; suggest `--optimize` if <90% |

---

## Error Handling

| Scenario | Response |
|----------|----------|
| Ambiguous request | Ask ONE clarifying question |
| Invalid frontmatter | Report specific YAML error with line |
| Missing domain | Default to `devops`, confirm with user |
| File exists | Warn, offer overwrite or rename |
| Review score < 70% | Suggest `tessl skill review --optimize` |
| Baseline ≈ With-context | Warn skill may add little value |
| Eval run failed | Suggest `tessl eval retry <id>` |

---

## Official Documentation

For complete Tessl documentation, see [docs/](docs/):

- [Creating Skills](docs/creating-skills.md) — How to create and publish skills
- [Creating Tiles](docs/creating-tiles.md) — Tiles containing skills, docs, and rules
- [Configuration Files](docs/configuration.md) — tile.json and tessl.json reference
- [Evaluate Skill Quality](docs/evaluate-skill-quality.md) — Scenario-based evaluations
- [Glossary](docs/glossary.md) — Key concepts and terminology
- [LLMs.txt Index](docs/llms.txt) — Full documentation index for AI consumption
