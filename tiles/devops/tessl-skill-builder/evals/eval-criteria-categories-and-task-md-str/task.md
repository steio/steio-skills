# Helm Chart Deployment Skill

## Problem/Feature Description

A platform engineering team wants to standardize how developers deploy Helm charts across their Kubernetes clusters. Currently each team follows different conventions and there is no shared guidance for agents to follow. The team wants to create a Tessl skill that guides AI coding agents through the Helm chart deployment workflow — including chart validation, value overrides, namespace targeting, and rollback procedures.

You have been asked to build the Tessl skill tile for this capability and include evaluation scenarios that the team can use to measure the skill's effectiveness. The evals will be used by the platform team to verify the skill is working well before publishing.

## Output Specification

Create a complete Tessl skill tile for a Helm chart deployment assistant. Place it under a suitable domain directory. The tile must include:

- `tile.json` and `SKILL.md`
- `AGENTS.md`
- At least 2 eval scenarios under `evals/`, each with a `task.md` and a `criteria.json`

The eval `criteria.json` files should reflect careful thinking about what makes a good evaluation for an agent skill. The `task.md` for each eval scenario should be structured with appropriate sections for context, the task to perform, and what success looks like.

Write all files to a subfolder in your working directory.
