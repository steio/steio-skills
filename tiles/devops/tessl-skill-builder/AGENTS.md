# tessl-skill-builder

Generate production-ready Tessl skills from prompts.

## WHERE TO LOOK

| Task | Location |
|------|----------|
| Primary skill | skills/tessl-skill-builder/SKILL.md |
| Companion skills | docs/companion-skills.md |
| Eval scenarios | evals/*/ |

## TILE STRUCTURE

```
tessl-skill-builder/
├── tile.json           # Tile manifest (name, version, skills)
├── AGENTS.md           # This file - project context
├── .tileignore         # Excluded files
├── skills/
│   └── tessl-skill-builder/SKILL.md
├── docs/               # Documentation
├── evals/              # Eval scenarios
│   └── <scenario>/
│       ├── task.md
│       └── criteria.json
└── rules/              # (optional) Steering rules
```

## CONVENTIONS

- Generated tiles follow Tessl spec: `tiles/<domain>/<name>/`
- Evals in `evals/<scenario>/` with `task.md` + `criteria.json`
- `private: true` until publishing
- Version starts at `0.1.0`, publish at `1.0.0`

## ANTI-PATTERNS

- Generating without clarification on ambiguous requests
- Skipping validators before reporting completion
- Starting version at `0.0.1` or `1.0.0`
- Forgetting to increment version before PR