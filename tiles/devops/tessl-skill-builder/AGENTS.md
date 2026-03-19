# tessl-skill-builder

Generate production-ready Tessl skills from prompts.

## WHERE TO LOOK

| Task | Location |
|------|----------|
| Primary skill | skills/tessl-skill-builder/SKILL.md |

## CONVENTIONS

- Generated tiles follow Tessl spec: `tiles/<domain>/<name>/`
- Evals in `evals/<scenario>/` with `task.md` + `criteria.json`
- `private: true` until publishing

## ANTI-PATTERNS

- Generating without clarification on ambiguous requests
- Skipping validators before reporting completion