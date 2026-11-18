# Feature Specification: Modern Web Guidance Skill

**Feature Branch**: `020-modern-web-guidance`

**Created**: 2026-11-18

**Status**: Draft

**Input**: User description: "can you add google modern web guidance skill, how are we mamaging skills in this nixos system"

## User Scenarios & Testing

### User Story 1 - Use modern web guidance in coding agents (Priority: P1)

As a user of Codex and OpenCode, I want the Google Chrome Modern Web Guidance skill installed through my NixOS-managed Home Manager configuration so that web implementation tasks can use current, searchable web platform guidance.

**Why this priority**: This is the requested capability and should work consistently across the configured agents.

**Independent Test**: Evaluate the Home Manager configuration and confirm both agent skill paths point at the pinned skill source.

**Acceptance Scenarios**:

1. **Given** either configured agent starts in a web UI or client-side JavaScript task, **When** it discovers available skills, **Then** it can load `modern-web-guidance`.
2. **Given** the skill is relevant, **When** the agent follows its instructions, **Then** it can decide how to invoke the recommended Modern Web Guidance CLI.

### User Story 2 - Understand skill ownership (Priority: P2)

As a maintainer, I want the system documentation to distinguish global Nix-managed skills from project-level skill discovery so I can update skills through the correct owner.

**Why this priority**: Clear ownership prevents edits to generated files and explains how this new skill fits existing configuration.

**Independent Test**: Read the current-system guide and identify the skill source, target agents, update mechanism, and project-level alternative.

**Acceptance Scenarios**:

1. **Given** a maintainer reviews current-system documentation, **When** they look up skills, **Then** it names the Home Manager module, six Nix skills, Google skill, and Vercel Skills CLI.

### Edge Cases

- The CLI is not part of this Nix installation; the agent uses the upstream instructions to choose how to invoke it.
- A package update changes the skill's guidance; the pinned skill source changes only through an explicit version and hash update.

## Requirements

### Functional Requirements

- **FR-001**: Home Manager MUST install the Modern Web Guidance skill for both Codex and OpenCode.
- **FR-002**: The skill source MUST be versioned and content-hash-pinned in the Nix configuration.
- **FR-003**: The installation MUST NOT add a Node runtime or CLI package as part of this feature.
- **FR-004**: The skill MUST preserve upstream guidance on how the agent may invoke the Modern Web Guidance CLI.
- **FR-005**: Current-system documentation MUST explain global skill management and project-level skill discovery.

### Key Entities

- **Agent skill**: Reusable instructions and resources discovered by a configured coding agent.
- **Pinned skill source**: The versioned Modern Web Guidance skill instructions and guides installed by Home Manager.

## Success Criteria

### Measurable Outcomes

- **SC-001**: Both configured agents have a discoverable `modern-web-guidance` skill after Home Manager activation.
- **SC-002**: The skill remains versioned and content-hash-pinned, and its upstream CLI guidance remains available to the agent.
- **SC-003**: Current-system documentation identifies the ownership and update path for global and project-level skills.

## Assumptions

- The supported system target remains `x86_64-linux` and uses Home Manager as a NixOS module.
- The GitHub release archive is used only as a fixed-output Nix source.
- Both Codex and OpenCode consume the shared `.agents/skills` format, with agent-specific Home Manager paths provided where required.
