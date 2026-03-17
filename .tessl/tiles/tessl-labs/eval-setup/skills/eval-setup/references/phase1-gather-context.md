# Phase 1: Gather Context

## 1.1 Identify the repository

Ask the user which repository to generate scenarios from. They need to provide it in `org/repo` format (e.g., `acme/payments-api`).

If you can infer the repo from the tile's context (e.g., a `scenario.json` already references a repo URL, or the tile name implies a repo), suggest it and confirm.

## 1.2 Identify the workspace

First verify the user is logged in:
```bash
tessl whoami
```

Then list available workspaces to find the correct workspace name:
```bash
tessl workspace list
```

**Important:** The `--workspace` flag requires the workspace **name** from `tessl workspace list`, NOT the username from `tessl whoami`. These are different values.

Store the workspace name — you'll need it for `scenario generate`, `eval run`, and `eval compare`. It is NOT needed for `scenario download` or `eval view`.

If the user has multiple workspaces, ask them to pick one.

## 1.3 Check for existing scenarios

Check if scenarios already exist on disk:
```bash
ls evals/*/task.md 2>/dev/null
```

If scenarios exist, warn the user:

> "You already have scenarios in `evals/`. Before proceeding, be aware that any old scenarios missing a `fixture.exclude` field in their `scenario.json` will cause `eval run` to fail. Options:
> 1. **Add more** — generate new scenarios into a subdirectory (e.g. `evals/<repo-name>/`)
> 2. **Replace all** — generate new scenarios and replace existing ones
> 3. **Skip generation** — just run evals on existing scenarios
>
> What would you prefer?"

If generating into a subdirectory, use `-o ./evals/<repo-name>/` for the download step.
