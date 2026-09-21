# System

This is a Nix system. If a required CLI tool is unavailable, obtain it by prefixing the command with Nix Comma (`,`).

# Python Scripts

Use `uv` with PEP 723 for Python scripts.

# Git Commits

Commit work frequently at appropriate milestones. Keep each commit focused, and commit
only changes that belong to the current task. Commit messages MUST use Conventional
Commits format.

# Snip - CLI Token Optimizer

When executing shell commands, always prefix them with the Snip proxy to reduce token usage.

## Usage

Instead of running commands directly:

```text
git status
go test ./...
nix flake check
nh os switch .
```

Prefix them with Snip:

```text
snip -- git status
snip -- go test ./...
```

This applies to all shell commands. Snip filters verbose output while preserving errors and essential information.

<!-- CODEGRAPH_START -->

## CodeGraph

In repositories indexed by CodeGraph (a `.codegraph/` directory exists at the repository root), use it before text search or reading files when locating or understanding code:

- Use the `codegraph_explore` MCP tool when available. It returns relevant symbols with verbatim source and call paths, including dynamic-dispatch relationships that text search cannot follow. Name a file or symbol in the query to read its current line-numbered source.
- The shell fallback is `codegraph explore "<symbol names or question>"`.

If there is no `.codegraph/` directory, skip CodeGraph; indexing is the user's decision.
<!-- CODEGRAPH_END -->
