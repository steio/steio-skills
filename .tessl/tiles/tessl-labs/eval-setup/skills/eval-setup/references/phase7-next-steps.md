# Phase 7: Recommend Next Steps

## 7.1 Summarize the setup

```
Eval setup complete!

  Repository:  <org/repo>
  Scenarios:   <N> scenarios from <M> commits
  Agents:      <list of agent:model pairs>
  Location:    ./evals/

  Results:
    Baseline average:   XX%
    With-tile average:  YY%
    Delta:              +ZZ
```

## 7.2 Suggest next actions

Based on the results, recommend (check in this priority order):

- **If baseline is already high (>= 80% on multiple scenarios):** "Warning: Your baseline scores are high, which means agents can solve these tasks without your tile. These scenarios aren't measuring tile value — they're measuring task triviality. Before improving your tile, you should **replace the easy scenarios** with ones generated from more complex commits. Go back to Phase 2 and select commits that touch more files and require deeper codebase understanding."
- **If regressions exist:** "Some criteria scored worse with your tile than without. This is highest priority — run `eval-improve` to diagnose and fix regressions."
- **If scores have room for improvement:** "Your tile is adding value but there's room to improve. Run the `eval-improve` skill to analyze which criteria need fixes and apply targeted edits."
- **If all scores are high (>= 85%):** "Your tile is performing well! Consider generating scenarios from more diverse commits to make sure it generalizes."

## 7.3 Offer to continue

Ask: **"Want me to run `eval-improve` now to analyze these results and start the improvement cycle?"**
