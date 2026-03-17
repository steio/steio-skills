# Phase 3: Generate Scenarios

## 3.1 Auto-detect context files

Before asking the user, scan the repo root for common context file patterns:
```bash
find . -maxdepth 3 \( -name "*.mdc" -o -name "CLAUDE.md" -o -name "AGENTS.md" -o -name "GEMINI.md" -o -name "tessl.json" -o -name "tile.json" -o -name ".tessl" \) -not -path "*/node_modules/*" -not -path "*/.git/*" 2>/dev/null | head -20
```

Based on what you find, propose a `--context` pattern:
- Found `.mdc` files → include `*.mdc`
- Found `CLAUDE.md` / `AGENTS.md` → include those explicitly
- Found `tessl.json` / `tile.json` → include those
- Found `.tessl/` directory → include `.tessl/`

Present your proposed pattern to the user and confirm before proceeding:

> "I found the following context files: [list]. I'll use `--context="<pattern>"`. Does that look right?"

If nothing is found, default to `*.mdc,*.md,tile.json,tessl.json,.tessl/` and confirm.

## 3.2 Run scenario generation

Pass all selected commits in a single command as a comma-separated list of short hashes:
```bash
tessl scenario generate <org/repo> \
  --commits=<hash1>,<hash2>,<hash3> \
  --context="<pattern>" \
  --workspace <workspace>
```

Use **short commit hashes** (7 characters), not full SHAs. For example:
```bash
tessl scenario generate TanStack/ai --commits=abc123,def456 --context="*.mdc" --workspace my-ws
```

The CLI polls until complete (~1–2 minutes per commit). Capture the **generation run ID** from the output — you'll need it for the download step.

> "Scenario generation typically takes 1–2 minutes per commit. I'll wait for it to complete."

## 3.3 Review what was generated

After generation completes, the CLI shows the generated scenarios. Summarize for the user:
- Number of scenarios per commit
- Scenario names/slugs

Ask: **"These look good? Want me to download them and proceed, or should I regenerate with different commits?"**
