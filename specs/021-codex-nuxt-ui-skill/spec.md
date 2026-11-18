# Feature Specification: Codex Nuxt UI Skill

**Feature Branch**: `021-codex-nuxt-ui-skill`

**Created**: 2026-11-18

**Status**: Draft

**Input**: User description: "Add the official Nuxt UI skill to this system through Home Manager and remove OpenCode from global skill management."

## User Scenarios & Testing

### User Story 1 - Use the Nuxt UI skill in Codex (Priority: P1)

As a Codex user, I want the official Nuxt UI skill installed declaratively so the agent can follow current Nuxt UI component and design guidance.

**Why this priority**: This is the requested capability.

**Independent Test**: Evaluate both supported Home Manager configurations and confirm the Codex skill set includes `nuxt-ui` from the pinned Nuxt UI repository.

**Acceptance Scenarios**:

1. **Given** either supported host configuration, **When** Home Manager evaluates, **Then** Codex receives the official `nuxt-ui` skill.
2. **Given** a new system evaluation, **When** the upstream branch changes, **Then** the configured skill source remains fixed to its recorded revision and hash.

### User Story 2 - Limit global skills to Codex (Priority: P2)

As a system maintainer, I want global Home Manager-managed skills targeted only to Codex.

**Why this priority**: This keeps the shared skill installation aligned with the requested agent target.

**Independent Test**: Evaluate both hosts and confirm nix-skills targets only Codex and OpenCode has no declared global skills.

**Acceptance Scenarios**:

1. **Given** either supported host configuration, **When** Home Manager evaluates, **Then** the nix-skills manager installs its selected skills for Codex only.
2. **Given** OpenCode remains installed, **When** Home Manager evaluates, **Then** no global skills are assigned to OpenCode.

## Edge Cases

- Both supported hosts must resolve the same pinned Nuxt UI source and skill target.
- Removing OpenCode as a skill target must not disable the OpenCode application or its unrelated configuration.

## Requirements

### Functional Requirements

- **FR-001**: Home Manager MUST install the official Nuxt UI `nuxt-ui` skill for Codex from a fixed revision and hash.
- **FR-002**: The Home Manager nix-skills manager MUST target Codex only.
- **FR-003**: The global OpenCode skill set MUST be empty while the OpenCode application remains configured.
- **FR-004**: Both supported hosts MUST receive identical global skill selections.
- **FR-005**: Current-system memory MUST describe the resulting skill ownership and targets.

## Success Criteria

- **SC-001**: Both host configuration evaluations pass with `nuxt-ui` present for Codex.
- **SC-002**: Both host configurations select only Codex as the nix-skills target and declare no OpenCode global skills.
- **SC-003**: The Nuxt UI source is pinned to an immutable revision with a fixed content hash.

## Assumptions

- “Remove OpenCode” means remove OpenCode from global skill targets, not uninstall the application.
- The official Nuxt UI `v4` skill is appropriate for this system and is pinned at the checked revision.
