# Build a Skill for Automated CSV Report Generation

## Problem/Feature Description

A data analytics team at a mid-sized e-commerce company regularly receives raw sales CSV files and needs them transformed into formatted summary reports. The process currently involves manual steps: filtering by date range, computing totals by category, and outputting a markdown summary with an executive summary section, key findings, and recommendations. The team lead wants to capture this as a reusable Claude skill so any team member (some non-technical) can invoke it reliably.

You've been asked to create the skill from scratch. The team lead has described the workflow: accept a CSV file path and an optional date range filter, compute per-category revenue totals and a grand total, flag any categories that are down more than 20% compared to the prior period, and emit a markdown report. The trigger phrases the team uses are things like "generate a sales report", "summarize the CSV", and "analyze this sales data". The output should always follow a consistent three-section structure.

## Output Specification

Create a complete skill directory at `./csv-report-skill/` with all necessary files. The skill should be immediately usable by another agent given only the directory path.

Produce a brief `design-notes.md` explaining the structural choices you made.
