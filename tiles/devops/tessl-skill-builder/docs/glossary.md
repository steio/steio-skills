# Glossary

This glossary defines the core concepts you'll encounter when working with Tessl.

## Tessl CLI

Tessl's command line tool for installing, updating and managing context for coding agents.

It enables users to:

* Create, install and manage agent skills and Tessl packages across their coding agents
* Publish skills and Tessl packages to the Tessl Registry
* Locally evaluate skills and Tessl packages

## Tessl Registry

Tessl's online registry for discovering and distributing agent context.

It enables users to:

* Discover agent skills and Tessl packages (tiles) and assess their quality (via evals)
* Connect their repositories to Tessl and automatically generate context for them
* Request new skills and Tessl context

## Skill

Agent Skills are folders of instructions, scripts, and resources that agents can discover and use to do things more accurately and efficiently, giving agents access to procedural knowledge and specific context they can load when the agent determines they're relevant (lazy push).

In Tessl, skills are treated as software with a complete lifecycle: versioned, evaluated, and maintained as dependencies and systems change.

See <https://agentskills.io/home> for more information.

## Tessl package (Tile)

Tessl packages (or tiles) are versioned bundles of reusable, agent-agnostic context that make coding agents more effective. They can (but do not always) contain:

* Skills
* Documentation (docs)
* Rules

Like software packages in npm or pip, Tessl packages are versioned, dependency-managed, and can be safely updated as libraries and systems evolve.

## Docs

Background information, often on different code libraries, loaded when the agent chooses (lazy pull via MCP).

## Rules

Mandatory steering for the agent to always follow, always pushed to the agent's context (eager push).

## Evaluations (evals)

Structured testing processes to systematically measure AI system performance, accuracy and reliability. Evaluations are typically contextual - they depend on the type of evaluation and the type of AI system or agent.

Tessl uses evaluations to validate that skills and context actually improve agent behavior, catch regressions as systems change, and ensure updates are safe before they reach production workflows.