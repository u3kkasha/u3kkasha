# Data Model: Home Manager Agent Context

## Shared Agent Context

- **Content**: Host-neutral Markdown instructions in `modules/home/agent-instructions.md`.
- **Invariant**: Codex and OpenCode receive identical content sourced from this one file.
- **Scope**: Global user context on both supported hosts.

## Configured Agent Client

- **Clients**: Codex and OpenCode only.
- **Invariant**: Each client receives its context through the Home Manager option belonging to that client.
- **Excluded client**: Antigravity CLI / Gemini is removed from configured programs, MCP projections, and global instruction destinations.

No persistent application data or state transition is introduced.
