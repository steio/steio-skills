# tessl-skill-builder

> Generate production-ready Tessl skills from prompts with full spec compliance.

[![Tessl Registry](https://img.shields.io/badge/Tessl-Registry-blue)](https://tessl.io/registry/steio-skills/tessl-skill-builder)
[![Version](https://img.shields.io/badge/version-0.3.7-green)](https://tessl.io/registry/steio-skills/tessl-skill-builder)
[![Quality](https://img.shields.io/badge/quality-93%25-brightgreen)](https://tessl.io/registry/steio-skills/tessl-skill-builder/quality)

## Overview

Meta-skill that generates production-ready Tessl skills from prompts. Combines **anthropic-skill-creator** (local fork) methodology with **Tessl-specific** templates for complete workflow: interview → draft → eval → publish.

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
Description optimization    →  GitHub Actions auto-publish
```

## Generated Output

```
tiles/<domain>/<name>/
├── tile.json           # Manifest with steio-skills/ namespace
├── AGENTS.md           # Project context
├── skills/
│   └── <name>/SKILL.md # Skill with valid frontmatter
├── docs/               # Optional documentation
└── evals/              # 2-3 eval scenarios
    └── <scenario>/
        ├── task.md
        └── criteria.json
```

## Complete Workflow

```
┌──────────────┐    ┌──────────────┐    ┌──────────────┐
│   INTERVIEW  │ → │   GENERATE   │ → │   VALIDATE   │
│   (ask Qs)   │    │  (draft tile)│    │ (lint/review)│
└──────────────┘    └──────────────┘    └──────────────┘
                                               │
                                               ▼
┌──────────────┐    ┌──────────────┐    ┌──────────────┐
│    PUBLISH   │ ← │     PR       │ ← │  LOCAL EVAL  │
│   (auto-CI)  │    │   (merge)    │    │ (baseline++) │
└──────────────┘    └──────────────┘    └──────────────┘
```

## Quality Metrics

| Metric | Score |
|--------|-------|
| Skill Review | 93% |
| Description | 100% |
| Content | 85% |
| Eval Scenarios | 7 |
| Eval (with context) | 99% |
| Eval (baseline) | 81% |
| Impact | +18pp delta |

## Dependencies

| Dependency | Source | Purpose |
|------------|--------|---------|
| `steio-skills/anthropic-skill-creator` | Local fork | Interview methodology, iteration workflow |

The `anthropic-skill-creator` is a local fork of [Anthropic's skill-creator](https://github.com/anthropics/skills) with weekly auto-sync from upstream.

## Documentation

| Document | Description |
|----------|-------------|
| [SKILL.md](skills/tessl-skill-builder/SKILL.md) | Main skill file |
| [docs/](docs/) | Tessl documentation |
| [docs/companion-skills.md](docs/companion-skills.md) | Related skills |
| [docs/configuration.md](docs/configuration.md) | tile.json reference |
| [docs/eval-criteria.md](docs/eval-criteria.md) | Eval categories |

## Companion Skills

| Skill | Purpose |
|-------|---------|
| `tessl-labs/eval-setup` | Generate and run eval scenarios |
| `tessl-labs/eval-improve` | Improve eval scores |
| `tessl-labs/compare-skill-model-performance` | Multi-model comparison |
| `nagaakihoshi/developing-tessl-skills` | Full lifecycle workflow |
| `tessl-labs/tile-creator` | Alternative tile creation |

## Security

This skill has been reviewed for security:
- ✅ No external repository dependencies (uses local fork)
- ✅ No arbitrary URL fetching
- ✅ Eval scenarios run in isolated environment

## License

Private tile for steio-skills workspace.

---

Maintained by [steio](https://github.com/steio).