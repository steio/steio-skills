# Set Up Evaluation Infrastructure for a Markdown-to-PDF Skill

## Problem/Feature Description

A developer has written a new `markdown-to-pdf` skill and wants to run a structured evaluation to measure whether it outperforms the baseline (no skill). The skill converts Markdown files into well-formatted PDFs using a consistent template. Two test cases have been identified: (1) converting a short project README into a PDF, and (2) converting a technical specification document with code blocks and tables.

Your job is to set up the complete evaluation directory structure and generate all the supporting artifact files that the evaluation harness expects. You should not actually run any LLM subagents — just build out the full scaffolding with realistic placeholder content so the harness can be wired up and run. This includes the workspace directory layout, metadata files for each eval, timing data stubs, example grading files, and the aggregated benchmark.

The skill is located at `./skills/markdown-to-pdf/`. Treat today's iteration as iteration 1.

## Output Specification

Create all evaluation scaffolding files in the appropriate directory structure. Include:
- The workspace directory and iteration directory
- Per-eval subdirectories for each test case
- Metadata, timing, and grading files for both with-skill and baseline (without-skill) runs for each eval
- Aggregated benchmark results at the iteration level

Also write a `setup-notes.md` at the workspace root explaining the structure you created and any decisions you made.
