# Feature Specification: Global Nix Skills

**Feature Branch**: `016-global-nix-skills`

**Created**: 2026-09-30

**Status**: Approved

**Input**: User description: "Keep skills.sh for other projects and manage global skills via this repo, using olafkfreund/nix-skills."

## User Scenarios & Testing

### User Story 1 - Load Nix guidance globally (Priority: P1)

As a maintainer, I want a selected set of Nix skills available to my global coding agents so they have reliable Nix, NixOS, Home Manager, Nixpkgs, and devenv guidance in every project.

**Why this priority**: This is the feature's core outcome.

**Independent Test**: Inspect the evaluated Home Manager configuration and confirm the selected skills are linked for Codex and OpenCode.

**Acceptance Scenarios**:

1. **Given** Home Manager activates, **When** Codex or OpenCode starts, **Then** the selected Nix skills are available in that agent's native skill directory.
2. **Given** the selected skill list is configured, **When** Home Manager evaluates it, **Then** no unselected upstream skill is installed.

### User Story 2 - Keep project skill discovery (Priority: P2)

As a maintainer, I want to retain the skills CLI so I can discover and use other skills in individual projects.

**Why this priority**: Global Nix guidance must not remove the existing project workflow.

**Independent Test**: Confirm the `skills` CLI remains in the Home Manager package set.

**Acceptance Scenarios**:

1. **Given** Home Manager activates, **When** the user runs the skills CLI, **Then** it remains installed for project-specific use.

### Edge Cases

- A newly added upstream skill name must be valid in the pinned nix-skills revision.
- The WSL and bare-metal Home Manager configurations must receive the same selected global skills.

## Requirements

### Functional Requirements

- **FR-001**: System MUST install selected Nix skills declaratively through Home Manager.
- **FR-002**: System MUST provide `nix-language`, `nix-workflow`, `nixpkgs-development`, `nixos-operations`, `home-manager`, and `devenv-project` skills.
- **FR-003**: System MUST install these skills for Codex and OpenCode.
- **FR-004**: System MUST retain the Vercel skills CLI for project-level discovery and use.
- **FR-005**: System MUST pin nix-skills through the repository flake lock.

## Success Criteria

### Measurable Outcomes

- **SC-001**: Both supported host configurations expose all six selected skills to Codex and OpenCode.
- **SC-002**: The `skills` CLI remains present in the Home Manager package set.
- **SC-003**: No other nix-skills skill is selected for global installation.

## Assumptions

- The upstream nix-skills Home Manager module supports the `codex` and `opencode` agent identifiers.
- Global skills are shared across both configured hosts, consistent with shared Home Manager defaults.
- Project-specific skills continue to be managed locally with the Vercel skills CLI.

## Current-System Impact

- Extends global agent tooling and pinned flake inputs; update the Home Manager and agent tooling sections of `.specify/memory/current-system.md` after implementation.
