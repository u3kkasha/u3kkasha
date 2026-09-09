# Data Model: Full Headroom Integration

## Full package

- **Identity**: Headroom v0.36.0 locked source and Cargo dependency graph
- **Capabilities**: all official complete-bundle feature groups
- **Dependencies**: private compatible Python set, Rust ML closure, native helper executables
- **Validation**: representative imports/operations for every group with network disabled
- **Relationships**: owns the MCP command and proxy process used by the Home Manager module

## Model asset set

- **Identity**: upstream repository, immutable commit revision, and fixed-output content hash
- **Contents**: model/tokenizer/OCR/encoding data required by default local paths
- **Validation**: discoverable through read-only offline cache paths; no fallback download
- **Relationship**: runtime dependency of the full package, not mutable user state

## Shared MCP registration

- **Identity**: `headroom`
- **Transport**: local stdio
- **Launch**: immutable full-package command with `mcp serve` arguments
- **Consumers**: Codex, Antigravity CLI, and OpenCode on both hosts
- **Validation**: initialize, tool discovery, compression, and exact retrieval round trip

## Opt-in Codex launcher

- **Identity**: `codex-headroom`
- **Lifecycle**: absent/inactive → loopback proxy starting → healthy/session running → cleaned up
- **Inputs**: user Codex arguments and existing Codex authentication
- **Outputs**: one proxied Codex session without persistent provider selection
- **Validation**: loopback-only address, readiness, cleanup, and byte-identical user configuration

## User-scoped Headroom state

- **Contents**: caches, memory, statistics, indexes, and logs created by explicit feature use
- **Authority**: disposable; never a source of declarative configuration or credentials
- **Lifecycle**: retained across package rollback unless the user removes it
- **Validation**: no state-version migration and no automatic deletion
