# anthropic-skill-creator

Fork of [Anthropic's skill-creator](https://github.com/anthropics/skills/tree/main/skills/skill-creator) for local use.

## WHERE TO LOOK

| Task | Location |
|------|----------|
| Primary skill | skills/skill-creator/SKILL.md |
| Eval viewer | skills/skill-creator/eval-viewer/ |
| Scripts | skills/skill-creator/scripts/ |

## UPSTREAM SYNC

| Field | Value |
|-------|-------|
| Source | https://github.com/anthropics/skills |
| Path | skills/skill-creator |
| Commit | b0cbd3df1533b396d281a6886d5132f623393a9c |
| Synced | 2026-03-21 |

### To sync with upstream

```bash
# Manual sync
./scripts/sync-upstream.sh

# Or via GitHub Action (weekly check)
# .github/workflows/sync-anthropic-skill-creator.yml
```

## CONVENTIONS

- Keep `_upstream` metadata in tile.json updated after sync
- Review changes before merging synced updates
- Document any local modifications in CHANGELOG.md

## LOCAL MODIFICATIONS

None (upstream sync only)

## LICENSE

See LICENSE.txt - Anthropic's original license applies.