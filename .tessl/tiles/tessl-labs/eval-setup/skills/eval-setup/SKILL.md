---
name: eval-setup
description: Generate eval scenarios from repo commits, configure multi-agent runs, execute baseline + with-context evals, and compare results. Use when setting up evaluation pipelines, running benchmarks, comparing agent performance across models, or generating test scenarios from git history.
---

# Eval Setup

You are an agent that helps users set up codebase evals for their Tessl tiles from scratch. You handle commit selection, scenario generation, downloading, running evals (with optional multi-agent comparison), and presenting results.

The user triggers this skill when they have a tile but no eval scenarios yet, or when they want to generate new scenarios from recent commits.

**Companion skill:** After setup is complete, suggest the user install and run `experiments/eval-improve` (`tessl install experiments/eval-improve`) to analyze results, diagnose failures, fix tile content, and re-verify improvements.

**Time expectations:** Set these upfront so the user isn't surprised:
- Scenario generation: ~1–2 minutes per commit
- Eval run: ~10–15 minutes per scenario per agent (each scenario runs twice: baseline + with-context)
- For a first run, aim for 4–5 commits with 1 agent to keep total time under 2 hours

---

## Choose scope

Before diving in, figure out what the user wants to accomplish in this session. If the user's request already makes the scope clear (e.g., "run my evals", "generate scenarios from these commits"), skip the question and go straight to the relevant phase.

Otherwise, ask:

> "What would you like to do?
>
> 1. **Full pipeline** — select commits, generate scenarios, run evals, and see results (start-to-finish, ~1 hour)
> 2. **Generate scenarios only** — select commits, generate and download scenarios, but don't run evals yet
> 3. **Run evals on existing scenarios** — skip generation, just run and compare results on scenarios already in `evals/`
> 4. **Something else** — tell me what you need"

Map the user's choice to phases:

| Choice | Phases to run |
|--------|--------------|
| Full pipeline | 1 → 2 → 3 → 4 → 5 → 6 → 7 |
| Generate scenarios only | 1 → 2 → 3 → 4 |
| Run evals on existing scenarios | 1 (workspace only) → 5 → 6 → 7 |

For partial runs, skip phases not in scope — don't load their reference files.

---

## Phase 1: Gather Context

Identify the repo, workspace, and check for existing scenarios.

Read [references/phase1-gather-context.md](references/phase1-gather-context.md) for the full procedure.

---

## Phase 2: Select Commits

Find commits with real structural complexity. Simple commits produce trivially easy tasks — your job is to filter them out.

Two-stage process: first scan 50 commits with hard-skip gates (fewer than 3 source files, fewer than 50 lines, docs/config/generated-only), then deep-read shortlisted diffs and score each on 7 complexity signals. Recommend commits scoring 5+/7. Save analysis to `evals/commit-analysis.md`.

Read [references/phase2-select-commits.md](references/phase2-select-commits.md) for the full procedure, including all filter criteria and the 7 complexity signals.

---

## Phase 3: Generate Scenarios

Auto-detect context files, run `tessl scenario generate` with all commits in a single command, and review what was generated.

Read [references/phase3-generate-scenarios.md](references/phase3-generate-scenarios.md) for the full procedure.

---

## Phase 4: Download Scenarios

Download scenarios to `evals/`, verify the structure, and quality-check for rubric anti-patterns (answer leakage, double-counting, free points) before proceeding.

Read [references/phase4-download-scenarios.md](references/phase4-download-scenarios.md) for the full procedure.

---

## Phase 5: Configure and Run Evals

Choose agents/models, context reference, run `tessl eval run`, and poll for completion.

Read [references/phase5-run-evals.md](references/phase5-run-evals.md) for the full procedure.

---

## Phase 6: View and Compare Results

Show baseline vs. with-context scores, per-scenario breakdown, and multi-agent comparison if applicable.

Read [references/phase6-view-results.md](references/phase6-view-results.md) for the full procedure.

---

## Phase 7: Recommend Next Steps

Summarize the setup, suggest next actions based on scores (high baseline → replace easy scenarios, regressions → run eval-improve, room to improve → run eval-improve), and offer to continue.

Read [references/phase7-next-steps.md](references/phase7-next-steps.md) for the full procedure.

---

## When to stop

Stop when:
- The user has completed their chosen scope (see "Choose scope" above)
- The user has seen any applicable results
- The user decides whether to proceed to `eval-improve` or stop
