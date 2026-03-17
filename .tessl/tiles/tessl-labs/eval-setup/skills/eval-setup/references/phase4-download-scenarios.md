# Phase 4: Download Scenarios

## 4.1 Download to disk

Download each generation run by its ID (not `--last` when multiple commits were used):
```bash
tessl scenario download <run-id-1> -o ./evals/
```

Repeat for each generation run ID. Use `--strategy merge` when adding to existing scenarios, `--strategy replace` only if the user explicitly asked to replace.

If downloading to avoid conflicts with existing scenarios, use a subdirectory:
```bash
tessl scenario download <run-id-1> -o ./evals/<repo-name>/
```

## 4.2 Verify the download

```bash
ls evals/*/task.md
```

Show the user the downloaded scenario structure:

```
Downloaded scenarios:
  evals/
    a1b2c3d-checkout-flow/
      task.md
      criteria.json
      scenario.json
    d4e5f6g-webhook-setup/
      task.md
      criteria.json
      scenario.json
```

## 4.3 Quality-check scenarios before running

Before asking the user, **read each `criteria.json` and `task.md` yourself** and flag these common problems:

**Rubric anti-patterns to catch:**
1. **Answer leakage** — Does `task.md` contain specific values (version numbers, URLs, class names) that are also rubric criteria? If a criterion just checks whether the agent copied a value from the task prompt, it's a free point. Remove the value from the task or remove the criterion.
2. **Double-counting** — Do two criteria reward the same underlying change? (e.g., "uses recommended config" and "removes deprecated config" for a single substitution). Merge them into one criterion.
3. **Free points** — Is `no_unrelated_changes` included as a criterion? This scores 1 on nearly every solution and doesn't discriminate. Remove it unless the scenario specifically tests scope discipline on a large codebase.

Present your findings:

> "I reviewed the downloaded scenarios. Here's what I found:
>
> **checkout-flow** — Looks good. 7 criteria covering integration, edge cases, and design patterns.
>
> **renovate-config** — Problem: This is a single-line config change. The rubric has 3 criteria but they all check the same substitution. I recommend removing this scenario and picking a more complex commit.
>
> **api-versioning** — Minor issue: criterion 'uses_correct_version' checks for version `3.18.0` which is already stated in task.md. I'd remove the version from the task or drop this criterion.
>
> Want me to fix these issues, remove the weak scenarios, or proceed as-is?"

Then offer the standard review options:

> "You can also:
> 1. **Review task.md** — see what the agent will be asked to do
> 2. **Review criteria.json** — see what the rubric checks for
> 3. **Edit criteria weights** — adjust which criteria matter most
> 4. **Proceed to eval run** — use the scenarios as-is"

If the user wants to review, read and display the relevant files. Apply any edits they request.
