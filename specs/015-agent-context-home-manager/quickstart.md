# Quickstart: Home Manager Agent Context

From the repository root, verify formatting and both-host generated configuration assertions:

```bash
nix build .#checks.x86_64-linux.formatting --no-link
nix build .#configuration-tests --no-link
```

Expected results: both configured clients receive matching content from the shared Markdown source; neither host configures Antigravity CLI or generates Gemini context; Codex and OpenCode MCP integration and OpenCode project instructions remain configured.
