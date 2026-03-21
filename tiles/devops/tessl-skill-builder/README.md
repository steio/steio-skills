# tessl-skill-builder

> Generate production-ready Tessl skills from prompts with full spec compliance.

[![Tessl Registry](https://img.shields.io/badge/Tessl-Registry-blue)](https://tessl.io/registry/steio-skills/tessl-skill-builder)
[![Version](https://img.shields.io/badge/version-0.3.0-green)](https://tessl.io/registry/steio-skills/tessl-skill-builder)
[![Quality](https://img.shields.io/badge/quality-93%25-brightgreen)](https://tessl.io/registry/steio-skills/tessl-skill-builder/quality)

## Overview

Meta-skill that generates production-ready Tessl skills from prompts. Combines **anthropic-skill-creator** methodology with **Tessl-specific** templates for complete workflow: interview → draft → eval → publish.

## Install

```bash
tessl install steio-skills/tessl-skill-builder
```

## Usage

```
User: "create a skill for managing PostgreSQL connection pools"

Agent: [uses tessl-skill-builder]
→ Asks clarifying questions
→ Generates SKILL.md, tile.json, evals, AGENTS.md
→ Runs validation
→ Prepares for publish
```

## Workflow

```
anthropic-skill-creator        tessl-skill-builder specifics
─────────────────────────     ─────────────────────────────
Interview & capture intent  →  Tessl namespace rules
Draft SKILL.md              →  tile.json + eval templates
Test & iterate              →  tessl eval run
Description optimization    →  GitHub Actions publish
```

## Generated Output

```
tiles/<domain>/<name>/
├── tile.json           # Manifest with steio-skills/ namespace
├── skills/
│   └── <name>/SKILL.md # Skill with valid frontmatter
├── docs/               # Optional documentation
├── evals/              # 2-3 eval scenarios
│   └── <scenario>/
│       ├── task.md
│       ├── criteria.json
│       └── scenario.json
└── AGENTS.md           # Project context
```

## Quality Metrics

| Metric | Score |
|--------|-------|
| Skill Review | 93% |
| Description | 100% |
| Content | 85% |
| Eval (with context) | 99% |
| Eval (baseline) | 81% |
| Impact | +18% delta |

## Integration with anthropic-skill-creator

Uses [anthropic-skill-creator](https://tessl.io/registry/steio-skills/anthropic-skill-creator) (local fork) for:
- Interview methodology
- Iteration workflow
- Description optimization

## Documentation

- [SKILL.md](skills/tessl-skill-builder/SKILL.md) — Main skill file
- [docs/](docs/) — Official Tessl documentation
- [Companion Skills](docs/companion-skills.md) — Related skills for full lifecycle

## Companion Skills

| Skill | Purpose |
|-------|---------|
| `tessl-labs/eval-setup` | Generate and run eval scenarios |
| `tessl-labs/eval-improve` | Improve eval scores |
| `tessl-labs/compare-skill-model-performance` | Multi-model comparison |
| `nagaakihoshi/developing-tessl-skills` | Full lifecycle workflow |
| `tessl-labs/tile-creator` | Alternative tile creation |

## License

Private tile for steio-skills workspace.

---

Maintained by [steio](https://github.com/steio).