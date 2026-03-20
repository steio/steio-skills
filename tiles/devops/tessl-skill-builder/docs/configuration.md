# Configuration files

## Tile configuration

### tile.json

The `tile.json` file is the configuration file for a tile. It includes important metadata that helps Tessl identify, version and describe tiles.

Tiles can contain three types of content:

* **docs**: Documentation files (markdown) that provide technical documentation, usage guides, API references, etc.
* **rules**: Rule files (markdown) that provide subjective guidance and instructions to agents, such as coding standards, best practices, and organizational policies.
* **skills**: Skill files (SKILL.md format) that extend AI coding agents with specialized knowledge, workflows, or tool integrations. Skills follow the [Agent Skills Specification](https://agentskills.io/specification).

A tile can contain one or more of these content types.

Here's an example `tile.json`:

```json
{
  "name": "tessl/npm-shadcn",
  "version": "3.6.0",
  "docs": "docs/index.md",
  "describes": "pkg:npm/shadcn@3.6.2",
  "summary": "CLI and programmatic API for adding UI components from registries.",
  "private": false
}
```

### tile.json Fields

**name** (string, required): Name for the tile in `workspace/tile-name` format

**version** (string, required): Semantic version of the tile

**summary** (string, required): Brief description of the tile

**entrypoint** (string, optional): Path to the markdown file shown first when someone opens the tile in the Tessl Registry UI. Defaults to `index.md`.

**private** (boolean, optional): Controls tile visibility in the registry. Set to `false` to make the tile publicly discoverable by all users, or `true` to restrict access to your workspace only. Defaults to `true` if not specified.

**docs** (string, optional\*): Path to tile documentation entrypoint (e.g. `"docs/index.md"`)

**describes** (string, optional\*): Package URL of the external package this tile documents.

**steering** (object, optional\*): An object mapping rule names to their markdown files. Used to provide subjective guidance and instructions to agents.

**skills** (object, optional\*): An object mapping skill names to their SKILL.md file paths. Each skill entry should have a `path` field pointing to the `SKILL.md` file.

\*Validation rules:
1. If **describes** is set, **docs** is required
2. Either **docs**, **steering**, or **skills** must be present

## .tileignore

Exclude files from tile validation and packing. Place a `.tileignore` file in the root of your tile directory (same level as `tile.json`).

**Default ignored files** (no .tileignore needed):
* `AGENTS.md`
* `CLAUDE.md`
* `GEMINI.md`

**Important rules:**
* Links to ignored files cause validation errors
* Manifest entrypoints (`docs`, `rules`, `skills`) cannot be ignored

**Example `.tileignore`:**

```gitignore
# Development notes
notes.md
TODO.md

# Draft files
*.draft.md
```

## Project configuration

### tessl.json

The `tessl.json` file is the manifest for your project's tile dependencies:

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

### Project Mode (Managed vs Vendored)

* **Managed mode** - Tile contents in `.tessl/tiles/` are gitignored like `node_modules`. Team members run `tessl install` after cloning.
* **Vendored mode** - Tile contents in `.tessl/tiles/` are committed to version control. Works offline without registry access.