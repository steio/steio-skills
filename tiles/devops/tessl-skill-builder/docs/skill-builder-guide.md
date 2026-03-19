# Tessl Skill Builder Guide

Reference for tessl-skill-builder tile.

## Generated Tile Pattern

```
tiles/<domain>/<name>/
├── tile.json
├── SKILL.md
├── evals/<scenario>/
│   ├── task.md
│   └── criteria.json
└── AGENTS.md
```

## Validation Checklist

- [ ] SKILL.md frontmatter valid
- [ ] tile.json valid, name matches `steio-skills/<slug>`
- [ ] Eval max_score sums to 100