# Redis Cache Monitoring Skill

## Problem/Feature Description

A backend team is dealing with frequent performance degradation in their Redis-backed services. Cache hit rates are dropping unexpectedly and the team lacks a systematic process for diagnosing and responding to these issues. They want to build an AI agent skill that monitors Redis cache performance, identifies hot keys and eviction patterns, and recommends tuning actions.

The team lead has asked you to scaffold the initial skill tile for this capability so other engineers can contribute to it. The tile is a new project and should follow all standard conventions for internal Tessl skill development. It should be organized under the right domain and should be easy to discover and navigate.

## Output Specification

Create a complete Tessl skill tile for a Redis cache monitoring assistant. Structure the tile correctly within an appropriate domain folder hierarchy. The tile must include:

- `tile.json` and `SKILL.md`
- `AGENTS.md`
- At least 2 eval scenarios under `evals/`, each with a `task.md` and `criteria.json`

All directory names, skill names, scenario folder names, and the tile name should follow the naming conventions used across the Tessl ecosystem. Write all files to a subfolder in your working directory.
