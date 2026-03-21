# Creating tiles

This section covers how to create custom Tessl packages (tiles) containing skills, documentation, and rules tailored to your team's specific needs.

## When to create tiles

Create custom tiles when you want to:

* **Codify team standards** - Capture your coding conventions, best practices, and style guidelines as rules
* **Share procedural knowledge** - Document workflows and processes as skills that team members can follow
* **Document internal libraries** - Generate and package documentation for your private codebases
* **Ensure consistency** - Make sure everyone on your team follows the same practices automatically

## What can you create?

### Skills

Procedural workflows that guide agents through complex tasks step-by-step.

**Example use cases:**

* API testing workflows
* Database migration procedures
* Deployment checklists
* Code review processes

**Learn more:** [Creating skills](creating-skills.md)

### Documentation

Technical documentation for libraries and frameworks that agents can query on-demand.

**Example use cases:**

* Internal library API documentation
* Framework usage guides
* Architecture decision records
* Technical specifications

### Rules

Mandatory coding standards and conventions that agents always follow.

**Example use cases:**

* Error handling patterns
* Validation requirements
* Response format conventions
* Security best practices
* Naming conventions

## Development workflow

1. **Develop locally** - Create and test your tile in your project
2. **Package as a tile** - Structure your skills, docs, and rules into a tile format
   * Skills: [Creating skills](creating-skills.md)
   * Docs: [Creating documentation](https://docs.tessl.io/create/creating-documentation)
3. **Distribute** - Share your tile with your team or the community
   * See [Distributing via registry](https://docs.tessl.io/distribute/distributing-via-registry)

## Related documentation

* [Glossary](glossary.md) - Understanding tiles, skills, docs, and rules
* [Configuration Files](configuration.md) - Tile configuration reference