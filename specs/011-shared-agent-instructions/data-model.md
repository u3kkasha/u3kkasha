# Data Model: Shared Agent Instructions

## Instruction Payload

- **Content**: Host-neutral Markdown guidance for global agent behavior.
- **Invariant**: A single value is reused without transformation.
- **Destinations**: `.codex/AGENTS.md` and `.gemini/GEMINI.md`.
- **Scope**: The configured Home Manager user on both supported hosts.

No persistent application data or state transition is introduced.
