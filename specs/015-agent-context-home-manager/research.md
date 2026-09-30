# Research: Home Manager Agent Context

## Decision: Use native context options for configured clients

- **Decision**: Configure `programs.codex.context` and `programs.opencode.context` with the shared instructions Markdown source.
- **Rationale**: The live Home Manager option index documents both options as accepting inline content or a file path and writing the respective global context file. The repository's locked Home Manager input must still be evaluated to confirm support before implementation is complete.
- **Alternatives considered**: Keep `home.file` mappings in a custom adapter, rejected because the two clients already expose native context options.

## Decision: Remove Gemini alongside Antigravity CLI

- **Decision**: Remove the Gemini instruction mapping and Antigravity-specific MCP projection with the unused CLI program.
- **Rationale**: The user clarified Gemini is the Antigravity CLI integration in this configuration, so no other Gemini client remains in scope.
- **Alternatives considered**: Keep a standalone Gemini global file, rejected because its only configured consumer is being removed.

## Decision: Preserve OpenCode project instruction loading

- **Decision**: Keep OpenCode's existing project instruction list while adding native global context.
- **Rationale**: Global and repository instruction discovery serve different scopes; removing the existing list could change current repository behavior.
- **Alternatives considered**: Replace the list with global context only, rejected because it drops repository-specific guidance.
