# Evaluate skill quality using scenarios

Tessl lets you run end-to-end task evaluations for your skills directly from the CLI. You generate a set of scenarios, run an agent against them, and see how well it performs — with and without your skill injected.

## Evals vs Reviews

The **Review Skills** feature reviews the skills against best practice, whereas **Evaluations** actually generates *scenarios* and then validate the quality of the skill, by testing if agents perform better against those scenario with the skill.

You will use **Lint**, **Review,** and **Scenario based evals**, to make an effective tile.

## Step 1: Generate evaluation scenarios

### Option A: CLI (quickest — requires an existing tile)

```sh
tessl scenario generate <path/to/tile> --count=5 --workspace=<workspace>
```

Generation runs server-side. Check progress with:

```sh
tessl scenario list --mine
```

Then download to disk once complete:

```sh
tessl scenario download --last
```

### Option B: Agent-assisted (recommended if starting from a standalone skill file)

First, install the scenario creator skill in your project:

```sh
tessl install tessl-labs/tessl-skill-eval-scenarios
```

Then prompt your agent (e.g. Claude):

```
"Create eval scenarios for <my_skill>"
```

### Option C: Write scenarios by hand

Create the directory structure manually:

```
evals/
├── instructions.json
├── scenario-1/
│     ├── task.md
│     ├── criteria.json
│     └── capability.txt
├── scenario-2/
└── ...

<your-skill-name>/
├── SKILL.md
└── tile.json
```

## Step 2: Run the evaluation

Pass the path to your `tile.json`:

```sh
tessl eval run <path/to/tile>
```

You can attach a label to a run:

```sh
tessl eval run <path/to/tile> --label "testing prompt changes"
```

By default, evals run using Claude Sonnet. You can specify a different model:

```sh
tessl eval run <path/to/tile> --agent=claude:claude-opus-4-6
tessl eval run <path/to/tile> --agent=claude:claude-haiku-4-5
```

## Step 3: Review your results

Use any of these to check status:

| Command | Description |
|---------|-------------|
| `tessl eval view <id>` | View a specific eval run |
| `tessl eval view --last` | List last eval run |
| `tessl eval list` | List all eval runs |
| `tessl eval retry <id>` | Retry a failed eval run |

## Step 4: Publish your Tile (Optional)

To publish your tile to the Tessl registry:

```sh
tessl tile publish
```

To publish without running a new eval:

```sh
tessl tile publish --skip-evals
```

**Note:** Tiles created through this flow are published as `private` by default. To make your tile public, update `tile.json`: setting `"private": false`.