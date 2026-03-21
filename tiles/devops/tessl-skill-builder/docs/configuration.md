# Configuration files

## Tile configuration

### tile.json

The `tile.json` file is the configuration file for a tile. It includes important metadata that helps Tessl identify, version and describe tiles.

Tiles can contain three types of content:

* **docs**: Documentation files (markdown) that provide technical documentation, usage guides, API references, etc.
* **rules**: Rule files (markdown) that provide subjective guidance and instructions to agents, such as coding standards, best practices, and organizational policies.
* **skills**: Skill files (SKILL.md format) that extend AI coding agents with specialized knowledge, workflows, or tool integrations. Skills follow the [Agent Skills Specification](https://agentskills.io/specification).

A tile can contain one or more of these content types. For example, a tile might have only documentation, only rules, only skills, or any combination of the three.

### Examples

**Docs-only tile (documenting an external package):**

```json
{
  "name": "tessl/npm-shadcn",
  "version": "3.6.0",
  "docs": "docs/index.md",
  "describes": "pkg:npm/shadcn@3.6.2",
  "summary": "CLI and programmatic API for adding UI components from registries. Supports multi-registry, dependency resolution, code transformation, and MCP integration for AI assistants.",
  "private": false
}
```

**Rules-only tile:**

```json
{
  "name": "myorg/code-style",
  "version": "0.0.1",
  "summary": "TypeScript code style guidelines for MyOrg",
  "private": true,
  "steering": {
    "naming": {
      "rules": "rules/naming.md"
    },
    "exceptions": {
      "rules": "rules/exceptions.md"
    }
  }
}
```

**Docs + rules tile:**

```json
{
  "name": "myorg/queue-connector",
  "version": "1.2.0",
  "summary": "Message queue SDK and its best practices for MyOrg",
  "docs": "docs/index.md",
  "steering": {
    "dead-letter-handling": {
      "rules": "rules/dead-letter-handling.md"
    },
    "dev-mode": {
      "rules": "rules/dev-mode.md"
    }
  }
}
```

**Skills-only tile:**

```json
{
  "name": "myworkspace/my-skill",
  "version": "1.0.0",
  "summary": "A skill that provides specialized functionality for my agent",
  "entrypoint": "README.md",
  "private": true,
  "skills": {
    "my-skill": {
      "path": "skills/my-skill/SKILL.md"
    }
  }
}
```

**Comprehensive tile (docs + rules + skills):**

```json
{
  "name": "myorg/comprehensive-tile",
  "version": "2.0.0",
  "summary": "Complete tile with docs, rules, and skills",
  "docs": "docs/index.md",
  "steering": {
    "code-style": {
      "rules": "rules/code-style.md"
    }
  },
  "skills": {
    "database-helper": {
      "path": "skills/database-helper/SKILL.md"
    }
  }
}
```

### Fields

**name** (string, required): Name for the tile in `workspace/tile-name` format

**version** (string, required): Semantic version of the tile

**summary** (string, required): Brief description of the tile

**entrypoint** (string, optional): Path to the markdown file shown first when someone opens the tile in the Tessl Registry UI. Defaults to `index.md`. Set this when you want the Registry to open a different file, such as `README.md`.

**private** (boolean, optional): Controls tile visibility in the registry. Set to `false` to make the tile publicly discoverable by all users, or `true` to restrict access to your workspace only. Defaults to `true` if not specified. Note: Authentication with `tessl login` is required to publish tiles regardless of this setting.

**docs** (string, optional\*): Path to tile documentation entrypoint (e.g. `"docs/index.md"`)

**describes** (string, optional\*): Package URL of the external package this tile documents.

**steering** (object, optional\*): An object mapping rule names to their markdown files. Used to provide subjective guidance and instructions to agents, rather than technical documentation.

**skills** (object, optional\*): An object mapping skill names to their SKILL.md file paths. Skills are reusable capabilities that extend AI coding agents with specialized knowledge, workflows, or tool integrations. Each skill entry should have a `path` field pointing to the `SKILL.md` file. Skills must follow the [Agent Skills Specification](https://agentskills.io/specification).

### Validation Rules

1. If **describes** is set, **docs** is required
2. Either **docs**, **steering**, or **skills** must be present in `tile.json`. You can include multiple content types.

---

## .tileignore

Exclude files from tile validation and packing.

**Purpose**

The `.tileignore` file allows you to exclude files from orphaned file warnings and prevent them from being included in published tile packages.

**Location**

Place a `.tileignore` file in the root of your tile directory (same level as `tile.json`).

**Syntax**

Uses gitignore-style patterns:

```gitignore
# Comments start with #

# Exact file names
notes.md

# Glob patterns
*.draft.md

# Directory patterns (trailing slash)
drafts/

# Recursive patterns
**/internal/**

# Path-specific patterns
docs/internal.md

# Negation patterns (exclude from ignore)
!important.md
```

**Default ignored files**

These files are always ignored, even without a `.tileignore` file:

* `AGENTS.md`
* `CLAUDE.md`
* `GEMINI.md`

**Important rules**

* **Links to ignored files cause errors**: If your docs link to a file that's in `.tileignore`, validation will fail. This prevents broken links in published tiles.
* **Manifest files can't be ignored**: You cannot put `docs`, `rules`, or `skills` entrypoints in `.tileignore`.

**Example `.tileignore`**

```gitignore
# Development notes
notes.md
TODO.md

# Draft files
*.draft.md

# Local testing
test-data/

# Keep this one even though it matches *.draft.md
!important.draft.md
```

---

## Project configuration

### tessl.json

The `tessl.json` file is the manifest for your project's tile dependencies. It specifies which tiles are installed and their versions:

```json
{
  "name": "my-project",
  "dependencies": {
    "workspace/tile-name": {
      "version": "1.0.0"
    }
  }
}
```

This file is created automatically when you run `tessl init` or `tessl install`. Tessl manages the dependencies in this file as you install or uninstall tiles.

### Project Mode (Managed vs Vendored)

The `mode` field in `tessl.json` controls how tile content is managed in your project. You can choose between two modes depending on your workflow and requirements:

#### Managed mode

**Default for existing projects** - Tile contents are gitignored like `node_modules`

```json
{
  "name": "my-project",
  "mode": "managed",
  "dependencies": {
    "workspace/tile-name": {
      "version": "1.0.0"
    }
  }
}
```

**Behavior:**

* Tile contents in `.tessl/tiles/` are automatically added to `.gitignore`
* Tiles are reinstalled from the registry based on `tessl.json`
* Works like package managers (npm, pip) - dependencies not committed
* Keeps repository clean and small
* Team members run `tessl install` after cloning the repository

**Best for:**

* Projects with frequent tile updates
* Teams who prefer lighter repositories
* Standard development workflows with internet access

#### Vendored mode

**Default for new projects** - Tile contents are committed to your repository

```json
{
  "name": "my-project",
  "mode": "vendored",
  "dependencies": {
    "workspace/tile-name": {
      "version": "1.0.0"
    }
  }
}
```

**Behavior:**

* Tile contents in `.tessl/tiles/` are committed to version control
* Exact tile versions are checked into the repository
* Works offline without registry access
* Team members get tiles automatically when cloning
* Ensures reproducible builds in all environments

**Best for:**

* Air-gapped or restricted network environments
* Projects requiring complete offline capability
* Ensuring exact reproducibility without external dependencies
* Compliance requirements for vendoring all dependencies

#### Switching modes

You can change modes at any time by updating the `mode` field in `tessl.json`:

```json
{
  "name": "my-project",
  "mode": "vendored",  // Change to "managed" or "vendored"
  "dependencies": {
    "workspace/tile-name": {
      "version": "1.0.0"
    }
  }
}
```

After changing the mode:

* Tessl will automatically update `.gitignore` accordingly
* In **managed mode**, `.tessl/tiles/` will be added to `.gitignore`
* In **vendored mode**, `.tessl/tiles/` will be removed from `.gitignore`
* Commit the changes to apply the new mode for your team

#### Default behavior

* **New projects** (running `tessl init` in a fresh project): Defaults to **vendored mode**
* **Existing projects** (running `tessl init` in a project with existing tiles): Defaults to **managed mode**
* You can explicitly set the mode in `tessl.json` to override the default

### .tessl directory

The `.tessl` directory contains Tessl's configuration and cached data:

```
.tessl/
|-- .gitignore                  # Ignores tiles/ and RULES.md (in managed mode)
|-- tiles/                      # Downloaded tiles
|   `-- workspace/
|       `-- tile-name/
|           |-- tile.json
|           |-- docs/            # Documentation files
|           |-- rules/           # Rule files
|           `-- skills/          # Skill files
|               `-- skill-name/
|                   `-- SKILL.md
`-- RULES.md                    # Generated rules for agents (not committed to git)
```

The `.tessl/.gitignore` file is automatically managed based on your project mode:

* **Managed mode**: The `tiles/` directory and `RULES.md` are added to `.gitignore` (not committed to version control)
* **Vendored mode**: The `tiles/` directory is removed from `.gitignore` (committed to version control), but `RULES.md` remains ignored as it's generated from tile content

### Agent rule files

Tessl creates and updates rule files for AI coding agents to help them understand your project context and installed tiles. The location and format of these files varies by agent:

* **Cursor**:
  * `.cursor/rules/tessl__*.mdc` - Tile-specific rules (auto-generated, not committed to git)
  * `.cursor/rules/tessl_context.mdc` - Instructions for gathering context from Tessl MCP
* **Claude Code**:
  * `CLAUDE.md` - Context file with instructions for gathering context from Tessl MCP
  * `.tessl/RULES.md` - Consolidated rules from all installed tiles
  * `AGENTS.md` - If this file exists, Tessl adds a reference to `.tessl/RULES.md`

These files are created when you run `tessl init --agent <agent-name>` or when Tessl auto-detects an agent in your project.

### MCP configuration files

When configuring AI agents, Tessl adds MCP (Model Context Protocol) server configuration to connect the agent to Tessl's MCP server. The location varies by agent:

* **Cursor**: `.cursor/mcp.json`
* **Claude Code**: `.mcp.json` in the project root

These files configure the agent to run `tessl mcp start` as an MCP server, enabling the agent to access Tessl's tools and context.

### AGENTS.md

The `AGENTS.md` file provides project context to AI coding agents. This file is similar to `CLAUDE.md` and other agent context files used by various AI coding assistants.

**Note**: Tessl does not create or manage `AGENTS.md` directly. However, if `AGENTS.md` exists in your project, Tessl will automatically add a reference to `.tessl/RULES.md` when you configure an agent with `tessl init`. This allows your agent to access tile-specific guidance and context.

If you're using `AGENTS.md` in your project:

* Add your own project context, coding conventions, and patterns
* Tessl will append a section linking to `.tessl/RULES.md` (marked with `<!-- tessl-managed -->`)
* The content is used by AI agents during code generation

---

## User preferences

Tessl stores user preferences globally to customize your experience. You can view and modify these preferences using the `tessl config` commands.

### Available preferences

* `shareUsageData` - Whether to share telemetry and usage data with Tessl (defaults to `true`)
* `agents` - Which agents to configure on `tessl init` (default to auto-detect when empty); see supported agents in `tessl init --help`.

### Managing preferences

View all current preferences:

```bash
tessl config get
```

View a specific preference:

```bash
tessl config get shareUsageData
```

Set a preference:

```bash
tessl config set shareUsageData false
```

### Opting out of telemetry

To opt out of sharing telemetry and usage data:

```bash
tessl config set shareUsageData false
```

For more information about data collection, see [Sharing Usage Data](https://docs.tessl.io/legal/sharing-usage-data).