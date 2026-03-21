---
name: tessl-skill-builder
description: Generate production-ready Tessl skills from prompts with full Tessl spec compliance. Creates SKILL.md, tile.json, eval scenarios, AGENTS.md, and docs. Auto-triggers on "create a skill", "build a skill", "generate a tessl skill", or when user wants to scaffold a new agent capability tile. Integrates with anthropic-skill-creator methodology for interview, draft, and iteration workflow.
---

# Tessl Skill Builder

Meta-skill that generates production-ready Tessl skills from prompts. Combines **anthropic-skill-creator** methodology with **Tessl-specific** templates for complete workflow: interview → draft → eval → publish.

## Architecture

```
anthropic-skill-creator        tessl-skill-builder specifics
─────────────────────────     ─────────────────────────────
Interview & capture intent  →  Tessl namespace rules
Draft SKILL.md              →  tile.json + eval templates
Test & iterate              →  tessl eval run
Description optimization    →  GitHub Actions publish
```

**Uses `anthropic-skill-creator` for:** interview methodology, iteration workflow, description optimization.
**Adds Tessl-specifics:** tile.json schema, eval format (category/context), registry publishing.

## Trigger Phrases

Activate when the user says: "create a skill", "build a skill", "generate a tessl skill", "scaffold a new skill", "make a tessl tile", "I want a skill for [domain]", or any request implying creating a new agent capability tile.

## Core Process

### Step 1: Capture Intent (MANDATORY)

**ALWAYS ask clarifying questions before generating. Use anthropic-skill-creator interview methodology:**

**⚠️ CRITICAL: This step is MANDATORY. Skipping it produces generic, low-quality tiles and is the #1 cause of skill failures.**

1. **Purpose**: What problem does this skill solve?
2. **When**: What user phrases/contexts should trigger it?
3. **Output**: What's the expected output format?
4. **Domain**: devops, backend, security, frontend, qa?
5. **Audience**: Which agent will use it? (Claude Code, Cursor, Copilot, OpenCode)
6. **Tools**: Which tools must the agent use?
7. **Test cases**: Should we set up evals? (Skills with objectively verifiable outputs benefit from test cases)

**Clarification Rules:**
- If the request is clear, ask at least ONE question to confirm understanding
- If ambiguous, ask multiple questions until unambiguous
- If user says "just generate it", ask: "What domain should this be in?"

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

Use anthropic-skill-creator iteration methodology:

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
description: <1-1024 chars, MUST be "pushy" - include trigger contexts>
---

# <Title>

## When to Use

**MANDATORY SECTION.** List specific trigger phrases and contexts. This section is critical for agent triggering.

<trigger phrases with examples>

## Core Process
<numbered workflow>

## Reference
<examples, patterns, anti-patterns>
```

### Frontmatter Fields (ALL REQUIRED)

| Field | Constraints |
|-------|-------------|
| `name` | kebab-case |
| `description` | 1-1024 chars, **MUST be "pushy"** |

### Pushy Description Examples

The `description` field is the PRIMARY triggering mechanism. Make it "pushy" by including BOTH what the skill does AND specific contexts:

**❌ Weak (under-triggers):**
```
description: Generate Terraform modules for AWS infrastructure.
```

**✅ Pushy (triggers correctly):**
```
description: Generate production-ready Terraform modules for AWS infrastructure. Use when user asks to "create a terraform module", "build infrastructure as code", "scaffold AWS resources", or mentions Terraform + AWS together. Triggers on requests for VPC, EC2, S3, RDS, Lambda, or any AWS resource automation.
```

**Why pushy matters:** Agents tend to under-trigger skills. A verbose description with multiple trigger contexts helps the agent recognize when to activate this skill.

### SKILL.md Body Structure

**MANDATORY sections in order:**

1. **`## When to Use`** — List specific trigger phrases, contexts, and user intents. This is NOT optional.
2. **`## Core Process`** — Numbered workflow steps.
3. **`## Reference`** — Examples, patterns, anti-patterns.

**Anti-pattern:** Do NOT put "when to use" information in body prose. Agents need explicit sections.

### Subdirectory Naming

Skills live in `skills/<skill-name>/SKILL.md`. The subdirectory name MUST match the skill name in frontmatter:

```
tiles/devops/redis-cache-monitor/
├── skills/
│   └── redis-cache-monitor/     ← matches skill name
│       └── SKILL.md
└── tile.json
```

**Common mistakes:**
- `skills/RedisCacheMonitor/` — uppercase
- `skills/redis_cache_monitor/` — underscores
- `skills/monitor/` — doesn't match skill name

### Test Prompts (Realistic Examples)

When creating test prompts for iteration, use CONCRETE, SPECIFIC requests:

**❌ Generic (unrealistic):**
```
"Create a skill for caching."
```

**✅ Realistic:**
```
"Our backend team is seeing 40% cache miss rates in Redis. 
Create a skill that helps diagnose cache performance issues 
and suggests optimization strategies. We use Redis 7.x with 
Spring Boot applications."
```

Include: specific technology, current problem, context about the team/stack.

### Script Bundling

For skills with **repeated logic** (validation, transformation, API calls), bundle a script:

```
tiles/<domain>/<name>/
├── skills/
│   └── <name>/
│       ├── SKILL.md
│       └── scripts/
│           └── validate.sh      ← bundled script
└── tile.json
```

**When to bundle:**
- Complex validation logic used in multiple steps
- API calls with specific auth/format requirements
- File transformations that are error-prone

**Reference in SKILL.md:**
```markdown
## Validation

Run the bundled validation script:

\`\`\`bash
./scripts/validate.sh <input>
\`\`\`
```

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

### Rules

- **Minimum 2 scenarios** per tile
- **max_score sums to 100** per criteria.json
- **Every checklist item must have category** — see [Eval Criteria Categories](../../docs/eval-criteria.md)
- **Use multiple category types** — not all INTENT
- **Criteria names specific and actionable**
- **context field required** in every criteria.json

---

## Evaluation Workspace Structure

For comprehensive eval workflows, use this directory structure alongside the tile:

```
workspace/
├── tiles/
│   └── <domain>/<name>/        ← tile source
└── eval-workspace/
    └── <tile-name>/
        ├── iteration-001/      ← numbered iterations
        │   ├── with-skill/     ← results with skill loaded
        │   │   ├── outputs/
        │   │   │   └── scenario-1/
        │   │   │       ├── result.json
        │   │   │       └── traces/
        │   │   ├── eval_metadata.json
        │   │   ├── timing.json
        │   │   └── grading.json
        │   ├── baseline/       ← results without skill
        │   │   ├── outputs/
        │   │   ├── eval_metadata.json
        │   │   ├── timing.json
        │   │   └── grading.json
        │   └── benchmark.json  ← comparison summary
        └── iteration-002/
```

### eval_metadata.json

```json
{
  "tile": "steio-skills/tessl-skill-builder",
  "version": "0.1.0",
  "agent": "claude:claude-sonnet-4-6",
  "scenarios_count": 3,
  "timestamp": "2026-03-21T12:00:00Z",
  "duration_seconds": 180
}
```

### timing.json

```json
{
  "total_duration_seconds": 180,
  "avg_per_scenario_seconds": 60,
  "scenarios": {
    "scenario-1": { "duration_seconds": 45, "turns": 12 },
    "scenario-2": { "duration_seconds": 75, "turns": 18 }
  }
}
```

### grading.json

```json
{
  "scenario-1": {
    "total_score": 85,
    "max_score": 100,
    "checks": {
      "valid-output": { "score": 20, "max_score": 20 },
      "correct-format": { "score": 15, "max_score": 20 }
    }
  }
}
```

### benchmark.json

```json
{
  "tile": "steio-skills/tessl-skill-builder",
  "iteration": 1,
  "comparison": {
    "with_skill_avg": 85,
    "baseline_avg": 60,
    "delta": 25
  },
  "scenarios": [
    {
      "name": "scenario-1",
      "with_skill": 90,
      "baseline": 70,
      "delta": 20
    }
  ]
}
```

**Important:** Always run `with-skill` BEFORE `baseline` to ensure fair comparison.

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

### Phase 5: Description Optimization

**CRITICAL for triggering accuracy.** After creating a skill, optimize the description:

#### Step 1: Generate Trigger Queries

Create `evals/description-queries.json`:

```json
{
  "should_trigger": [
    "create a terraform module for S3",
    "I need to build infrastructure as code",
    "scaffold AWS resources with Terraform"
  ],
  "should_not_trigger": [
    "create a Python script for data processing",
    "help me write a React component",
    "generate documentation for my API"
  ]
}
```

**Requirements:**
- Minimum 10 should-trigger queries
- Minimum 10 should-not-trigger queries (near-misses, not obviously irrelevant)
- Queries must be concrete and specific

#### Step 2: Run Optimization Loop

Use `run_loop.py` to test description variants:

```python
#!/usr/bin/env python3
"""Description optimization loop for skill triggering."""

import json
import subprocess
import sys

def run_eval(description: str, queries: dict) -> float:
    """Test a description variant against queries."""
    # Update SKILL.md with new description
    # Run trigger eval
    # Return score
    pass

def main():
    with open("evals/description-queries.json") as f:
        queries = json.load(f)
    
    descriptions = [
        "Generate Terraform modules for AWS.",
        "Generate production-ready Terraform modules for AWS infrastructure. Use when...",
    ]
    
    for desc in descriptions:
        score = run_eval(desc, queries)
        print(f"Score: {score:.2f} | {desc[:50]}...")

if __name__ == "__main__":
    main()
```

**Run with:**
```bash
python run_loop.py --max-iterations 10 --model claude:claude-sonnet-4-6
```

**Parameters:**
- `--max-iterations`: Number of description variants to test (default: 10)
- `--model`: Agent to use for eval (e.g., `claude:claude-sonnet-4-6`)
- `--threshold`: Minimum acceptable trigger score (default: 90)

#### Step 3: Apply Best Description

Select the description with highest trigger accuracy. Prioritize:
1. Correct should-trigger rate (> 90%)
2. Low false positive rate (should-not-trigger < 10%)
3. Conciseness (under 1024 chars)

### Phase 6: Publish to Registry

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
