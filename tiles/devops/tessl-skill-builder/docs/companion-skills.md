# Companion Skills

After generating a tile, the full development lifecycle uses these Tessl tiles. Install and invoke as needed.

## Integrated: `anthropic-skill-creator` (Local Fork)

**Install:** `tessl install steio-skills/anthropic-skill-creator`
**Upstream:** https://github.com/anthropics/skills (weekly auto-sync)
**Integrated with:** tessl-skill-builder (orchestrates internally)

**What anthropic-skill-creator adds:**
- Interview methodology for capturing intent
- Iteration workflow (draft → test → improve → repeat)
- Description optimization for better triggering
- Eval-viewer for qualitative review

**When tessl-skill-builder uses it:**
- Step 1: Capture Intent — interview methodology
- Step 4: Test & Iterate — iteration workflow
- Step 5: Optimize Description — trigger optimization

---

## For Evals: `tessl-labs/eval-setup`

**Install:** `tessl install tessl-labs/eval-setup`
**Triggers:** "set up evals", "generate eval scenarios", "benchmark my tile"

Full pipeline: commit selection → scenario generation → run baseline + with-context evals → compare results.

## For Improving Evals: `tessl-labs/eval-improve`

**Install:** `tessl install tessl-labs/eval-improve`
**Triggers:** "improve my eval scores", "fix failing criteria", "analyze eval results"

Full cycle: classify scores into buckets (working/gap/redundant/regression) → diagnose root causes → apply fixes → re-run → verify.

## For Multi-Model Comparison: `tessl-labs/compare-skill-model-performance`

**Install:** `tessl install tessl-labs/compare-skill-model-performance`
**Triggers:** "compare models", "test across agents", "validate for different models"

Runs evals across multiple models (claude-haiku, claude-sonnet, claude-opus) and compares results.

## For Full Lifecycle: `nagaakihoshi/developing-tessl-skills`

**Install:** `tessl install nagaakihoshi/developing-tessl-skills`
**Triggers:** "prepare for PR", "publish my skill", "full development workflow"

Full lifecycle: `tessl skill review --optimize` → increment version → `tessl skill lint` → stage for PR.

## For Tile Creation: `tessl-labs/tile-creator`

**Install:** `tessl install tessl-labs/tile-creator`
**Triggers:** "create tile from existing content", "convert repo to tile"

Alternative creation method using MCP tool (`mcp__tessl__new_tile`) or CLI. Three types: docs (facts), skills (workflows), rules (constraints).