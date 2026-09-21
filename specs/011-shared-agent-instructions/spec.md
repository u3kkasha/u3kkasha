# Feature Specification: Shared Agent Instructions

**Feature Directory**: `011-shared-agent-instructions`

**Created**: 2026-09-21

**Status**: Draft

**Input**: "Rewrite the global Codex and Gemini instructions, manage both with Home Manager, keep them identical, and describe the environment generically as a Nix system for both NixOS and NixOS-WSL."

## Intent and Scope

### Problem

The global Codex and Gemini instruction files are mutable runtime files with slightly
different wording. They describe only NixOS-WSL even though this flake supports both
bare-metal NixOS and NixOS-WSL.

### Desired Outcome

Both supported hosts receive identical global Codex and Gemini instructions from the
declarative configuration. The instructions describe the environment simply as a Nix
system and preserve the useful Nix Comma, Python, Snip, and CodeGraph guidance.

### Out of Scope

- Managing Antigravity CLI's runtime state below `~/.gemini/antigravity-cli/`.
- Changing agent packages, MCP configuration, or project-local instructions.

## Affected Targets

| Target or layer                  | Affected? | Expected observable change                                 |
| -------------------------------- | --------- | ---------------------------------------------------------- |
| `nixos` host                     | Yes       | Receives both identical global instruction files           |
| `nixos-wsl` host                 | Yes       | Receives both identical global instruction files           |
| Shared NixOS modules             | No        | N/A                                                        |
| Shared Home Manager modules      | Yes       | Owns one shared instruction payload and two destinations   |
| Developer shell or agent tooling | Yes       | Codex and Gemini consume matching global instructions      |
| CI, caching, or verification     | Yes       | Configuration assertions cover both hosts and destinations |

## User Scenarios & Testing

### User Story 1 - Consistent Global Instructions (Priority: P1)

As the configured user, I receive the same global operating guidance in Codex and
Gemini on either supported host.

**Why this priority**: Divergent mutable guidance produces inconsistent agent behavior.

**Independent Test**: Evaluate both Home Manager host configurations and confirm that
both instruction destinations contain exactly the same expected text.

**Acceptance Scenarios**:

1. **Given** either supported host configuration, **When** Home Manager evaluates the
   global agent files, **Then** Codex and Gemini receive byte-identical content.
2. **Given** the shared instructions, **When** their system description is inspected,
   **Then** it says the environment is a Nix system without claiming it is always WSL.

### Edge Cases

- An existing mutable instruction file is replaced through the repository's normal Home
  Manager activation and backup behavior.
- Antigravity's runtime directory remains application-owned; Gemini's supported global
  instruction path is `~/.gemini/GEMINI.md`.

## Requirements

### Functional Requirements

- **FR-001**: The configuration MUST declaratively own `~/.codex/AGENTS.md`.
- **FR-002**: The configuration MUST declaratively own `~/.gemini/GEMINI.md`.
- **FR-003**: Both destinations MUST be generated from one identical instruction payload.
- **FR-004**: The payload MUST identify the environment only as a Nix system and retain
  Nix Comma, Python with uv/PEP 723, Snip, and conditional CodeGraph guidance.
- **FR-005**: Both supported host configurations MUST expose the same two files.

### Invariants

- **INV-001**: Existing Codex, Antigravity, MCP, and host-boundary behavior MUST remain unchanged.
- **INV-002**: Automatic module discovery MUST retain an exact-list unit assertion.

### Security and State

- **SEC-001**: The feature introduces no credentials, privileges, trust, sockets, or secrets.
- **STATE-001**: Activation may back up pre-existing mutable files; state versions remain unchanged.

## Success Criteria

### Measurable Outcomes

- **SC-001**: Configuration tests prove four generated files—two destinations on each of
  two hosts—contain exactly one shared expected payload.
- **SC-002**: Unit and configuration tests pass without changing existing agent integrations.

## Current-System Impact

- **Claims to update**: Home Manager and Agent Tooling ownership of global Codex and Gemini instructions.
- **Limitations resolved or introduced**: Removes mutable, divergent global agent instructions; no new limitation.

## Assumptions

- Gemini's global instruction file is `~/.gemini/GEMINI.md`; no instruction file belongs
  at `~/.gemini/antigravity-cli/GEMINI.md`.
