# Phase 6: View and Compare Results

## 6.1 View detailed results

```bash
tessl eval view --last
```

Show the user the overall scores and per-scenario breakdown.

## 6.2 Compare with breakdown

For a comprehensive view of baseline vs. with-context across all scenarios:

```bash
tessl eval compare ./evals/ --breakdown --workspace <workspace>
```

This shows:
- Aggregate baseline vs. with-context scores
- Per-scenario detail with all runs
- Color-coded results: green (>= 80%), yellow (>= 50%), red (< 50%)

Present the key findings to the user:

```
Eval Results Summary:

  Scenario                  Baseline  With-Tile  Delta
  checkout-flow              42%       87%       +45  ✅
  webhook-setup              38%       72%       +34  🟡
  error-recovery             65%       91%       +26  ✅
  api-versioning             71%       68%        -3  🔴 regression

  Overall:                   54%       80%       +26

Key observations:
  - checkout-flow: Tile adds significant value (+45 points)
  - api-versioning: Tile may be causing confusion (-3 regression)
  - webhook-setup: Good improvement but still below 80% threshold
```

## 6.3 Multi-agent comparison (if applicable)

If multiple agents were tested, show a comparison:

```
Agent Comparison:

  Agent                     Avg Score   Best Scenario          Worst Scenario
  claude:claude-sonnet-4-6   80%       checkout-flow (87%)    api-versioning (68%)
  cursor:auto                74%       error-recovery (85%)   webhook-setup (58%)

Observations:
  - Claude Sonnet scores highest on average
  - Cursor performs best on error-recovery
  - Both agents struggle with webhook-setup — likely a tile gap
```
