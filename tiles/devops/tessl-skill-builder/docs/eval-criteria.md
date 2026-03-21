# Eval Criteria Categories

When creating evaluation criteria for skills, use these categories in the `category` field of criteria.json:

| Category | Purpose |
|----------|---------|
| `INTENT` | Core feature/behavior the change introduces |
| `DESIGN` | Architectural or structural choices |
| `MUST_NOT` | Things the solution should avoid |
| `MINIMALITY` | Appropriate scope — no overreach |
| `REUSE` | Leveraging existing patterns |
| `INTEGRATION` | How solution connects with existing code |
| `EDGE_CASE` | Boundary conditions handled correctly |

## Example criteria.json

```json
{
  "context": "Evaluates skill generation from prompt",
  "type": "weighted_checklist",
  "checklist": [
    { "name": "valid_frontmatter", "description": "SKILL.md has valid YAML frontmatter", "max_score": 20, "category": "INTENT" },
    { "name": "correct_structure", "description": "Tile follows Tessl directory structure", "max_score": 20, "category": "DESIGN" },
    { "name": "no_placeholders", "description": "No TBD or TODO placeholders remain", "max_score": 20, "category": "MUST_NOT" },
    { "name": "focused_scope", "description": "Skill has single clear purpose", "max_score": 20, "category": "MINIMALITY" },
    { "name": "follows_patterns", "description": "Matches existing tile conventions", "max_score": 20, "category": "REUSE" }
  ]
}
```

## Rules

- **Minimum 2 scenarios** per tile
- **max_score sums to 100** per criteria.json
- **Category must be valid** — one of the 7 categories above
- **Names specific and actionable** — avoid vague criteria

## Related

- [Evaluate Skill Quality](evaluate-skill-quality.md) — Full evaluation workflow
- [Configuration Files](configuration.md) — tile.json reference