# steio-skills

AI Engineering Platform built with [Tessl](https://tessl.io) - A package manager for agent skills and context.

## Overview

This repository implements a monorepo of tiles (skill packages) for AI coding agents. Each tile contains skills, documentation, and evaluations that enable agents to perform specialized tasks correctly and consistently.

## Architecture

```
steio-skills/
├── tiles/                    # Tile packages by domain
│   ├── devops/              # DevOps & Infrastructure
│   │   ├── namecheap-terraform/
│   │   └── github-actions/
│   ├── backend/             # Backend development
│   │   └── code-review/
│   └── security/            # Security & compliance
│       └── code-audit/
├── shared/                   # Shared resources
│   ├── templates/           # Skill templates
│   └── prompts/             # Standard prompts
├── scripts/                  # Utility scripts
└── .github/workflows/        # CI/CD automation
```

## Available Tiles

| Tile | Version | Description |
|------|---------|-------------|
| `steio-skills/namecheap-terraform` | 1.0.1 | Manage Namecheap DNS records with Terraform |
| `steio-skills/github-actions` | 1.0.0 | Create and optimize CI/CD pipelines |
| `steio-skills/code-review` | 1.0.0 | Review PRs for quality, security, performance |
| `steio-skills/security-audit` | 1.0.0 | Scan for vulnerabilities and secrets |

## Quick Start

### Install Tessl CLI

```bash
curl -fsSL https://get.tessl.io | sh
```

### Install a Tile

```bash
# In your project directory
tessl install steio-skills/github-actions
```

### Use with AI Agents

Tiles are automatically detected by AI agents (Claude Code, Cursor, etc.) when phrases match the skill triggers.

Example triggers:
- "create ci pipeline" → `create-ci-pipeline` skill
- "review this pr" → `review-pr` skill
- "security audit" → `vulnerability-scanner` skill

## Tile Structure

Each tile follows the Tessl specification:

```
tiles/<category>/<tile-name>/
├── tile.json          # Tile metadata
├── SKILL.md           # Main skill definition
├── skills/            # Additional skills (optional)
│   └── <skill-name>/
│       └── SKILL.md
├── docs/              # Reference documentation
└── evals/             # Evaluation scenarios
    └── <scenario>/
        ├── task.md
        └── criteria.json
```

### tile.json Example

```json
{
  "name": "steio-skills/<tile-name>",
  "version": "1.0.0",
  "summary": "Brief description",
  "private": true,
  "docs": "docs/reference.md",
  "skills": {
    "<skill-name>": {
      "path": "SKILL.md"
    }
  }
}
```

### SKILL.md Example

```markdown
---
name: skill-name
description: What this skill does
triggers:
  - trigger phrase 1
  - trigger phrase 2
---

# Skill Name

Workflow and instructions for the agent...

## Important Rules
- Rule 1
- Rule 2
```

## CI/CD Workflows

### Automatic Publishing

When changes are pushed to `main`, tiles are automatically published to the Tessl Registry.

```yaml
# Triggered by: git push origin main
# Detects: Changed files in tiles/
# Publishes: Only changed tiles
```

### PR Reviews

Pull requests with skill changes get automatic quality reviews:

1. **Lint** - Validates tile structure
2. **Review** - Scores skill quality (threshold: 50%)
3. **Comment** - Posts results on PR

### Workflow Files

| File | Purpose |
|------|---------|
| `.github/workflows/publish-tiles.yml` | Auto-publish on main |
| `.github/workflows/review-skills.yml` | Skill quality review |
| `.github/workflows/lint-tiles.yml` | Structure validation |

## Creating a New Tile

1. **Create directory structure:**

```bash
mkdir -p tiles/<category>/<tile-name>/{skills,docs,evals}
```

2. **Create tile.json:**

```json
{
  "name": "steio-skills/<tile-name>",
  "version": "1.0.0",
  "summary": "Description",
  "private": true,
  "docs": "docs/reference.md",
  "skills": {
    "<skill-name>": { "path": "SKILL.md" }
  }
}
```

3. **Create SKILL.md:**

```markdown
---
name: <skill-name>
description: What it does
triggers:
  - trigger phrase
---

# Skill Name

[Instructions for the agent]
```

4. **Update tessl.json:**

```json
{
  "dependencies": {
    "steio-skills/<tile-name>": {
      "source": "file:./tiles/<category>/<tile-name>"
    }
  }
}
```

5. **Install locally:**

```bash
tessl install
```

6. **Commit and push:**

```bash
git add .
git commit -m "feat: add <tile-name> tile"
git push
```

## Evaluation Scenarios

Evaluations measure skill effectiveness. Create them in `evals/<scenario>/`:

```
evals/
└── scenario-name/
    ├── task.md          # Task description for the agent
    └── criteria.json    # Success criteria for scoring
```

### task.md Example

```markdown
Create a GitHub Actions workflow for a Node.js project with:
- Node 20
- npm caching
- Test and build jobs
```

### criteria.json Example

```json
{
  "criteria": [
    {
      "name": "Uses setup-node action",
      "type": "file_contains",
      "value": "actions/setup-node"
    },
    {
      "name": "Has npm cache",
      "type": "file_contains",
      "value": "cache: 'npm'"
    }
  ]
}
```

## Shared Resources

### Templates

Located in `shared/templates/` - reusable skill patterns:
- Basic skill template
- Debugging skill template
- Generation skill template

### Prompts

Located in `shared/prompts/` - standardized prompts for common tasks:
- Code generation prompts
- Review prompts
- Debugging prompts

## Development

### Prerequisites

- [Tessl CLI](https://docs.tessl.io) installed
- GitHub account with repo access
- TESSL_API_TOKEN secret configured

### Local Development

```bash
# Clone repository
git clone https://github.com/steio/steio-skills.git
cd steio-skills

# Install tiles locally
tessl install

# Validate tile structure
tessl tile lint tiles/<category>/<tile-name>

# Review skill quality
tessl skill review tiles/<category>/<tile-name>/SKILL.md

# Optimize skill
tessl skill review --optimize tiles/<category>/<tile-name>/SKILL.md
```

### Testing Changes

Before pushing:

1. Run lint: `tessl tile lint tiles/<category>/<tile-name>`
2. Run review: `tessl skill review tiles/<category>/<tile-name>/SKILL.md`
3. Verify score is above 50%

## Registry

Tiles are published to the [Tessl Registry](https://tessl.io/registry):

- `steio-skills/namecheap-terraform` - [View](https://tessl.io/registry/steio-skills/namecheap-terraform)
- `steio-skills/github-actions` - [View](https://tessl.io/registry/steio-skills/github-actions)
- `steio-skills/code-review` - [View](https://tessl.io/registry/steio-skills/code-review)
- `steio-skills/security-audit` - [View](https://tessl.io/registry/steio-skills/security-audit)

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make changes following tile structure guidelines
4. Run lint and review locally
5. Submit a pull request

## Resources

- [Tessl Documentation](https://docs.tessl.io)
- [Tessl Registry](https://tessl.io/registry)
- [Tessl Discord](https://discord.com/invite/jbb2vHnHZQ)
- [Agent Skills Specification](https://docs.tessl.io/skills/)

## License

Private - steio organization

---

Built with [Tessl](https://tessl.io) - The package manager for agent skills.