# Phase 2: Select Commits

Good eval scenarios come from commits that are genuinely challenging for coding agents. Simple commits (single-method fixes, narrow patches, pattern-following additions) produce tasks that agents solve trivially — often 100% baseline — making them useless as eval datapoints. Your job is to find commits with real structural complexity.

This phase has four steps: scan, deep-read, save analysis, and recommend.

## 2.1 Scan recent commits

Use `git log --oneline --stat --no-merges -50` (or `gh api` if the repo isn't cloned locally) to review recent commits with their diff stats. If fewer than 5 candidates survive filtering, expand to `-100`.

Apply these filters in order:

**Hard-skip gates** — skip the commit immediately if ANY of these are true:
- Fewer than 3 source files changed
- Fewer than 50 lines of source code changed (exclude test files, fixtures, and generated code from the count)
- All changed files are documentation (README, changelog, comments)
- All changed files are config or infra (Dockerfile, CI/CD, `.env`, `docker-compose.yml`)
- All changed files are auto-generated (lock files, migration boilerplate)

**Soft-skip signals** (avoid unless nothing better is available):
- Changes concentrated in a single directory or package
- Commit message suggests a narrow fix ("fix crash when...", "handle edge case...", "add option to...")

**Prefer signals** (actively seek these):
- 4+ source files across 2+ directories
- New files created (especially new modules or classes)
- 100+ lines of source code changed
- Commit message suggests a new system or feature ("Add X support", "Implement Y", "Migrate to Z")

**Output:** a shortlist of commit candidates — aim for 2–3x the target number of scenarios (e.g., 8–15 candidates if targeting 4–5 scenarios).

## 2.2 Deep-read top candidates

This is the key step. For each shortlisted candidate, read the actual diff:

```bash
git diff <hash>~1..<hash>
```

Score each candidate on these 7 complexity signals (1 point each):

1. **New abstractions** — new classes, interfaces, data structures, or modules introduced
2. **Cross-cutting scope** — changes span multiple subsystems, layers, or packages
3. **Wiring and registration** — new components are integrated with existing systems (routes, DI, config, event buses)
4. **Non-obvious control flow** — callbacks, event handlers, middleware chains, async coordination, state machines
5. **Domain-specific logic** — requires understanding concepts not obvious from code structure alone
6. **Multiple interdependent changes** — the changes only make sense together; can't implement them one at a time
7. **No single-point solution** — cannot be replicated by changing one method or copying an existing pattern

**Reject candidates where the diff reveals:**
- Single-method bug fix (guard clause, null check, error handler addition)
- Mechanical pattern repetition (copy existing code, change names/values)
- Narrow security fix (swap function, remove flag, add import)
- 80%+ of the diff is test files, fixtures, or generated code
- Change an experienced developer could implement in <15 minutes without codebase context

## 2.3 Save commit analysis report

Write the full analysis to `evals/commit-analysis.md` (or `evals/<repo-name>/commit-analysis.md` if using a subdirectory). This file records:

- **Scan results:** which commits were shortlisted and why, which were skipped and why (group skipped commits by reason)
- **Deep-read results:** for each candidate, the 7-signal complexity score, key observations from the diff, and the accept/reject decision with reasoning
- **Final recommended commits table:** the commits you'll present to the user in 2.4

This serves as an audit trail so the user can review the selection rationale, revisit rejected candidates later, and compare against eval results to further calibrate the selection criteria over time.

## 2.4 Recommend commits

Present your top candidates as a ranked table with:
- Commit hash and message
- Complexity score (X/7)
- Which complexity signals each candidate hits
- A short reason why it would make a good eval

Recommend **4–5 commits** for a first run, strongly preferring candidates scoring **5+/7**.

If the user specifies their own commits (by hash, range, or selecting all), respect their choices — but warn on any commit scoring **<3/7** and explain why it may produce a trivially easy eval scenario.

Collect the confirmed commit hashes for the next step.
