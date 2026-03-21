# Optimize Triggering for a Data-Cleaning Skill

## Problem/Feature Description

A developer has built a `data-cleaner` skill that normalizes messy datasets: it handles duplicate removal, fixes inconsistent date formats, standardizes column names, and fills in missing values using configurable strategies. The skill has been working well in direct tests, but users report that Claude sometimes handles cleaning tasks on its own without consulting the skill, missing the specialized logic for edge cases. The developer wants to optimize the skill's description field to improve triggering accuracy.

The current skill description reads: "Cleans and normalizes tabular data. Use when you need to remove duplicates, fix date formats, standardize column names, or fill missing values."

To do this properly, an eval set is needed that tests whether the optimized description correctly triggers (and doesn't overtrigger) across a range of realistic user queries. Your job is to produce this eval set as a JSON file, then use it to demonstrate how you would invoke the optimization script.

## Output Specification

Produce the following files:

1. `trigger-eval.json` — the eval set with 20 queries, each with `query` (string) and `should_trigger` (boolean) fields. Queries must be realistic and specific — written as something an actual Claude Code or Claude.ai user would type, with personal context, file paths, column names, or company details as appropriate. Include 8–10 should-trigger and 8–10 should-not-trigger queries. Put special thought into the negative cases — the most useful ones are not obviously off-topic.

2. `run-optimization.sh` — a shell script showing the exact command you would run to execute the optimization loop, using placeholder values where needed but with all flags and arguments correct.

3. `optimization-notes.md` — brief notes explaining: (a) how you decided which queries to mark as should-not-trigger, and (b) what model ID you would use in the `--model` flag and why.
