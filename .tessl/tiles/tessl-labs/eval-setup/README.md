# eval-setup — Codebase Eval Generation & Execution Pipeline

This is a Tessl skill (published as `experiments/eval-setup`) that automates the full eval setup pipeline: from browsing commits to generating scenarios, running multi-agent evals, and comparing results. It's the companion to `eval-improve` — this skill creates the eval foundation, that skill iterates on the results.

## Install

```bash
tessl install experiments/eval-setup
```

> **Companion skill:** This skill pairs with [eval-improve](https://tessl.io/registry/experiments/eval-improve) (`tessl install experiments/eval-improve`), which takes over after evals are running — analyzing results, diagnosing failures, fixing tile content, and re-verifying. Use `eval-setup` first, then `eval-improve` to iterate.

## What it does

### Phase 1 — Gather Context
Identifies the repo, workspace, and checks for existing scenarios on disk. Offers to merge new scenarios with existing ones or replace them.

### Phase 2 — Select Commits
Uses a two-stage analysis to find genuinely challenging commits. First, scans the last 50 commits with hard-skip gates (e.g., <4 source files, <50 lines of source code) and prefer signals (new modules, cross-directory changes, 100+ lines). Then, deep-reads shortlisted diffs and scores each on 7 structural complexity signals — new abstractions, cross-cutting scope, wiring/registration, non-obvious control flow, domain-specific logic, interdependent changes, and no single-point solution. Recommends commits scoring 5+/7 and saves the full analysis to `evals/commit-analysis.md` as an audit trail.

### Phase 3 — Generate Scenarios
Runs `tessl scenario generate` with your chosen commits and context patterns. Polls for completion, reviews what was generated, and asks for approval before downloading.

### Phase 4 — Download Scenarios
Downloads scenarios to `evals/` with merge or replace strategy. Automatically quality-checks downloaded scenarios for common rubric anti-patterns (answer leakage, double-counting criteria, free-point criteria like `no_unrelated_changes`, trivially easy tasks). Offers to review and edit `task.md` and `criteria.json` before running.

### Phase 5 — Configure and Run Evals (multi-agent)
Supports multi-agent comparison across:

| Agent | Models |
|-------|--------|
| `claude` | `claude-sonnet-4-6` (default), `claude-opus-4-6`, `claude-sonnet-4-5`, `claude-opus-4-5`, `claude-haiku-4-5` |
| `cursor` | `auto`, `composer-1.5` |

Each agent runs baseline (no context) and with-context automatically. You choose the context reference point (`infer`, `HEAD`, or a specific commit SHA). The skill asks you which agents to test and explains the cost tradeoffs before running.

### Phase 6 — View and Compare Results
Uses `tessl eval compare --breakdown` for detailed baseline vs. with-context scoring per scenario. For multi-agent runs, shows a side-by-side comparison:

```
Agent Comparison:

  Agent                     Avg Score   Best Scenario          Worst Scenario
  claude:claude-sonnet-4-6   80%       checkout-flow (87%)    api-versioning (68%)
  cursor:auto                74%       error-recovery (85%)   webhook-setup (58%)
```

### Phase 7 — Recommend Next Steps
Based on scores, suggests whether to run `eval-improve`, generate more diverse scenarios, or tighten eval criteria.

## Human in the loop

The skill asks for your confirmation at every decision point:
- Which commits to use for scenario generation
- How many scenarios to generate
- Whether to review/edit scenarios before running
- Which agents and models to test
- Whether to proceed to `eval-improve` after seeing results

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
