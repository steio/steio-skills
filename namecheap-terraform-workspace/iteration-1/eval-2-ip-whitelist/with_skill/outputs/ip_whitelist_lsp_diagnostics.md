IP Whitelist Diagnostics - MD File

- Issue: LSP diagnostics attempted on a Markdown file but no MD extension support is configured in the environment.
- Result: No LSP server available for .md files. The environment recommended LSP servers for code (e.g., TS/JS, Python) do not apply to Markdown files.
- Next steps: For MD content, rely on manual review or render checks. If you want automated diagnostics for Markdown, configure a Markdown LSP or use a general text linter (e.g., markdownlint).

Summary: LSP-based diagnostics were not available for the Markdown file ip_whitelist_troubleshooting.md. This is a known limitation of the current IDE/LSP setup in this environment.
