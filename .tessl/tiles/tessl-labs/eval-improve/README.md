# eval-improve — Automated Eval-Driven Tile Improvement Loop

This is a Tessl skill (published as `experiments/eval-improve`) that automates the cycle of analyzing, diagnosing, fixing, and re-verifying a Tessl tile based on its eval results. It's designed for tile authors who have already run evals and want to systematically improve their scores.

## Install

```bash
tessl install experiments/eval-improve
```

> **Companion skill:** This skill pairs with [eval-setup](https://tessl.io/registry/experiments/eval-setup) (`tessl install experiments/eval-setup`), which handles the upstream pipeline — generating scenarios from repo commits, configuring multi-agent runs, and running the first round of evals. If you don't have scenarios yet, start with `eval-setup`.

## The core workflow has 6 phases

### Phase 0 — Detect Starting Point

The skill automatically detects your current state and routes accordingly:
- **Eval results exist** → proceeds straight to analysis (Phase 1)
- **Scenarios exist but no results** → offers to run `tessl eval run` first
- **No scenarios at all** → points you to the companion `eval-setup` skill (`experiments/eval-setup`) to generate scenarios from repo commits

This means you can invoke `eval-improve` at any point and it will figure out what to do next.

### Phase 1 — Analyze Results

Runs both `tessl eval view --last --json` and `tessl eval compare --breakdown` to get detailed per-criterion scores and aggregate baseline vs. with-context comparisons. Then classifies every criterion into one of four buckets:

- **Bucket A (Working well):** With-context score >= 80% of max and better than baseline. Leave these alone.
- **Bucket B (Tile gap):** Low score both with and without tile context. Highest-impact fix opportunities.
- **Bucket C (Redundant):** Baseline already scores >= 80% — the agent knows this without your tile. Consider removing the criterion.
- **Bucket D (Regression):** With-context score is *worse* than baseline — the tile is actively confusing the agent. Highest priority to investigate.

Example output:
```
Eval Analysis for: payments-gateway

Scenario: checkout-flow (baseline: 42% -> with-tile: 72%)

  Bucket B — Tile Gaps (fix these):
    - "Webhook signature validation" — 5/10 (baseline 1/10)
      Diagnosis: Tile mentions webhooks but not signature validation
      File to fix: skills/payments/SKILL.md

  Bucket D — Regressions (investigate):
    - "API version pinning" — 4/10 (baseline was 6/10)
      Diagnosis: Tile's version guidance may conflict with existing patterns

  Bucket C — Redundant:
    - "HTTP status codes" — baseline 9/10, tile 10/10
      Note: Agents already handle this. Consider removing.

  Bucket A — Working well (1 criterion): [collapsed]
```

### Phase 2 — Diagnose Root Causes

For each Bucket B/D item, reads the `criteria.json` rubric and the tile files (`skills/`, `rules/`, `docs/`), identifies what the rubric expects vs. what the tile actually says, and flags gaps, ambiguities, and cross-file contradictions.

### Phase 3 — Apply Fixes

Proposes minimal, targeted edits (matching the rubric's exact language), shows each change to the user before applying, lints after each edit, and handles each bucket type differently:
- **Bucket B (gaps):** Adds missing content, using the rubric's exact phrasing
- **Bucket C (redundant):** Offers to remove the criterion, make the task harder, or keep as a sanity check
- **Bucket D (regressions):** Clarifies or removes content that confused the agent

### Phase 4 — Re-run & Verify

Commits changes (with user approval), re-runs evals via `tessl eval run --force`, polls until complete, and runs `tessl eval compare --breakdown` to show the full before/after:

```
Before -> After:

  checkout-flow:         72% -> 91%  (+19) ✅
  webhook-setup:         68% -> 85%  (+17) ✅
  error-recovery:        91% -> 93%  (+2)  ✅
  api-versioning:        68% -> 82%  (+14) ✅

  Average:               75% -> 88%  (+13)
```

Offers to iterate on remaining gaps.

### Phase 5 — Scenario Quality Review (optional)

Audits the eval scenarios themselves — flagging unrealistic tasks, poorly weighted criteria, or missing coverage.

## The evals included

The tile ships with 5 eval scenarios that test the skill itself:

1. **eval-bucket-classification** — Can the agent correctly sort criteria into the four buckets?
2. **targeted-tile-editing** — Does it make minimal, precise edits?
3. **cross-file-contradiction-detection** — Can it spot contradictions across tile files?
4. **regression-root-cause-analysis** — Can it diagnose why a regression happened?
5. **redundant-criteria-management** — Does it properly handle Bucket C criteria?

## How the two skills work together

```
eval-setup                           eval-improve
─────────────────────────           ─────────────────────────
commits → scenarios → run evals  →  analyze → diagnose → fix → re-run → verify
         ↑                                                               │
         └─────────── generate new scenarios for next round ─────────────┘
```

### What each skill covers

| What you need to do | eval-setup | eval-improve |
|---|---|---|
| Pick which commits to use | Guides the decision with filtering | — |
| Choose context patterns | Explains patterns, suggests defaults | — |
| Generate scenarios from diffs | Runs generation, polls, reviews | — |
| Edit scenarios before running | Offers review of task.md and criteria.json | — |
| Choose agents/models | Presents options, explains cost tradeoffs | — |
| Run evals | Runs with configured agents, polls, retries failures | Re-runs after fixes |
| Compare baseline vs. with-context | `eval compare --breakdown` + multi-agent tables | `eval compare --breakdown` on every iteration |
| Interpret what scores mean | Observations + recommendations | 4-bucket classification (Working/Gap/Redundant/Regression) |
| Diagnose why a score is low | — | Reads rubric + tile files, finds gaps and contradictions |
| Fix the tile content | — | Proposes minimal edits matching rubric language, lints |
| Verify fixes worked | — | Re-runs, compares before/after, offers another pass |
| Audit scenario quality | — | Reviews task realism, criteria weighting, coverage gaps |

### Expanding on the docs

The official Tessl docs at `docs.tessl.io/evaluate/evaluating-your-codebase` describe the CLI commands and flags. These two skills turn that reference into an opinionated, agent-driven workflow:

- **Decision guidance at every step** — the docs tell you *what* each command does; the skills tell the agent *when* to use it and *what to ask you* first
- **Multi-agent comparison workflow** — the docs show the `--agent` flag; `eval-setup` turns it into a guided experience with comparison tables
- **The 4-bucket framework** — not in the docs; `eval-improve` introduces a structured way to classify and act on results
- **Cross-file contradiction detection** — not in the docs; `eval-improve` scans tile files for conflicting instructions
- **Iterative improvement loop** — the docs describe a one-shot pipeline; together the skills create a repeatable cycle

## In short

It's a **meta-skill** — a skill that helps you improve other skills by automating the "run evals, read results, figure out what's wrong, fix it, verify" loop.
