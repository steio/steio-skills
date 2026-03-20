# Creating skills

Skills are reusable capabilities that extend AI coding agents with specialized knowledge, workflows, or tool integrations. Tessl makes it easy to create, publish, and share skills with your team or the broader community through the Tessl Registry.

This guide walks you through creating a skill, publishing it, and installing it so your agent can use it.

## Prerequisites

Before you begin, make sure you have:

* Tessl CLI installed (see [Installation](https://docs.tessl.io/introduction-to-tessl/installation))
* Authenticated with Tessl (`tessl login`)
* A workspace created (see [Workspace management](https://docs.tessl.io/reference/cli-commands#workspace-management))

## Creating a skill

### Step 1: Create a new skill

Use the `tessl skill new` command to create a new skill. You can run it interactively or with flags:

**Option 1: Interactive wizard (recommended for first-time users)**

```sh
tessl skill new
```

This launches an interactive wizard that guides you through creating the skill.

**Option 2: Create with flags**

You can create a skill with all parameters specified:

```sh
# Create a new skill
tessl skill new --name "database-migration-helper" --description "When you need to create and manage database migrations" --workspace myworkspace --path ./my-skill
```

The command creates a new directory with a `SKILL.md` file following the Agent Skills specification. See the [CLI commands reference](https://docs.tessl.io/reference/cli-commands#tessl-skill-new) for all available options.

**Option 3: Import an existing skill**

If you already have a skill (e.g., from a local directory), you can import it:

```sh
# Import from a local directory
tessl skill import ./path/to/my-skill --workspace myworkspace

# Import and make it public
tessl skill import ./my-skill --workspace myworkspace --public
```

This validates and imports the skill into your workspace. See the [CLI commands reference](https://docs.tessl.io/reference/cli-commands#tessl-skill-import) for all import options.

### Step 2: Write your skill

Your skill file must be named `SKILL.md` and should contain the skill definition following the Agent Skills format. For the complete specification, see:

* [Agent Skills Specification](https://agentskills.io/specification) - The official Agent Skills format specification
* [Anthropic Agent Skills Documentation](https://docs.anthropic.com/en/docs/agents-and-tools/agent-skills/overview) - Anthropic's official documentation for Agent Skills

#### Example SKILL.md

Here's what a well-documented `SKILL.md` file looks like:

```markdown
---
name: database-migration-helper
description: When you need to create and manage database migrations.
---

# Database Migration Helper

## Creating a Migration

When creating a new migration:

1. Always include both `up` and `down` migrations
2. Use transactions when possible
3. Test migrations on a copy of production data first

### Example: Adding a Column

    -- Up migration
    ALTER TABLE users ADD COLUMN email_verified BOOLEAN DEFAULT FALSE;

    -- Down migration
    ALTER TABLE users DROP COLUMN email_verified;


## Best Practices

* Never modify existing migrations that have been applied to production
* Always test rollbacks
* Keep migrations small and focused
```

**Key components:**

* **YAML frontmatter** (required):
  * `name`: The skill identifier (lowercase, hyphens only)
  * `description`: Clear description of the trigger when skill should activate - this is critical for skill discovery by agents
* **Markdown body**: Concise instructions, examples, and guidance

**Important:** Keep the documentation simple and focused. The frontmatter `description` helps agents discover your skill, while the body provides clear, actionable guidance.

#### Understanding the Tessl package structure

When you create a skill with `tessl skill new`, it creates a Tessl package structure with a `tile.json` manifest file:

```
my-skill/
├── tile.json          # Package manifest
└── SKILL.md          # Your skill file
```

The `tile.json` file looks like this:

```json
{
  "name": "myworkspace/database-migration-helper",
  "version": "1.0.0",
  "summary": "Helper for creating and managing database migrations",
  "private": true,
  "skills": {
    "database-migration-helper": {
      "path": "SKILL.md"
    }
  }
}
```

**Key fields:**

* **name**: Package name in `workspace/skill-name` format
* **version**: Semantic version ([semver](https://semver.org/))
* **skills**: Maps skill names to their `SKILL.md` file paths

You typically don't need to manually edit `tile.json` unless you're updating the version for a new release. For more details on the tile structure and configuration options, see [Configuration files](configuration.md).

### Step 3: Validate your skill against best practices

Before publishing, validate your skill structure and contents:

```sh
tessl skill lint ./my-skill
```

This command checks:

* `SKILL.md` format and structure
* Required frontmatter fields (name, description)
* Conformance to the Agent Skills specification
* Markdown validity

For a more comprehensive review with detailed recommendations:

```sh
tessl skill review ./my-skill
```

Fix any errors before proceeding.

### Step 4: Evaluate quality using scenarios

Once you've built your skill the final step before publishing is to create scenarios your skill can be evaluated against. See [Evaluate skill quality using scenarios](evaluate-skill-quality.md).

### Step 5: Publish your skill

Publish your skill to the Tessl Registry:

```sh
tessl skill publish ./my-skill --workspace myworkspace
```

By default, skills are published as private. This means only members of your workspace can install them.

If you're in the skill directory, you can omit the path:

```sh
cd my-skill
tessl skill publish --workspace myworkspace
```

To make a skill public (after approval):

```sh
tessl skill publish --workspace myworkspace --public
```

After publishing, your skill will be available in the Tessl Registry and can be installed by members of your workspace.

## Installing a skill

Once published (as private or public), you or your team members can install the skill in any project:

```sh
tessl install myworkspace/my-skill
```

Or install a specific version:

```sh
tessl install myworkspace/my-skill@1.0.0
```

Skills are installed as part of Tessl packages and automatically made available to your configured agent.

## Updating a skill

To update a published skill:

1. Make your changes to the `SKILL.md` file
2. Update the version number in `tile.json` (following [semantic versioning](https://semver.org/))
3. Validate with `tessl skill lint` or `tessl skill review`
4. Publish the new version with `tessl skill publish`

**Important:** Always increment the version in `tile.json` when publishing updates. Use semantic versioning:

* **Patch** (1.0.0 → 1.0.1): Bug fixes, minor improvements
* **Minor** (1.0.0 → 1.1.0): New features, backward-compatible changes
* **Major** (1.0.0 → 2.0.0): Breaking changes

## Best practices

* **Use SKILL.md format**: Skills must be named `SKILL.md` and follow the Agent Skills specification
* **Write clear descriptions**: The `description` in your frontmatter is critical for skill discovery
* **Keep skills focused**: Each skill should have a single, clear purpose
* **Test before publishing**: Use `tessl skill lint` and `tessl skill review` to validate
* **Document clearly**: Include concise instructions and examples in your `SKILL.md` body
* **Version carefully**: Always update the version in `tile.json` before publishing updates

## Related documentation

* [Agent Skills Specification](https://agentskills.io/specification) - The official Agent Skills format specification
* [Creating Tiles](creating-tiles.md) - How to create tiles with skills, docs, and rules
* [Configuration Files](configuration.md) - Complete reference for `tile.json` structure