# Feature Specification: Global Official .NET Skills

**Feature Branch**: `023-global-dotnet-skills`

**Created**: 2026-11-18

**Status**: Approved

**Input**: User description: "I want to add all offical dotnet skills to this system via the current flake"

## User Scenarios & Testing

### User Story 1 - Use official .NET guidance globally (Priority: P1)

As a user, I want all skills published by the .NET team available to Codex on either configured host so that .NET work receives the relevant official guidance without per-project installation.

**Why this priority**: This is the requested outcome.

**Independent Test**: Evaluate either supported host's Home Manager configuration and inspect its generated Codex skill links against the pinned upstream skill catalog.

**Acceptance Scenarios**:

1. **Given** the system is activated on either supported host, **When** Codex starts, **Then** every upstream plugin skill containing a `SKILL.md` at the pinned revision is available globally.
2. **Given** upstream adds or removes a skill, **When** the pinned source revision is updated, **Then** the generated global skill set follows that revision without maintaining a duplicated name list.

### Edge Cases

- Skills with the same leaf name across plugin groups must remain independently addressable.
- Directories without a `SKILL.md` must not be exposed as skills.
- The upstream revision and content hash must remain pinned together for reproducible evaluation.

## Requirements

### Functional Requirements

- **FR-001**: System MUST install every official .NET skill present under the upstream `dotnet/skills` plugin skill directories at the pinned revision.
- **FR-002**: System MUST install those skills for Codex through Home Manager on both supported hosts.
- **FR-003**: System MUST derive the skill set from the pinned source so it cannot silently drift from the lock/source declaration.
- **FR-004**: System MUST omit non-skill plugin components such as host-specific custom agents and MCP servers.
- **FR-005**: System MUST retain the existing Modern Web Guidance and Nuxt UI skills.

## Success Criteria

### Measurable Outcomes

- **SC-001**: Both supported host configurations expose every `SKILL.md` under the pinned official plugin catalog to Codex.
- **SC-002**: Each generated skill link has a unique name, including when upstream skill leaf names overlap.
- **SC-003**: Existing global skills remain available after the .NET skills are added.

## Assumptions

- "Official .NET skills" means skills published by the .NET team in `dotnet/skills`, not separate Microsoft repositories.
- The scope is skills only; plugin MCP servers and GitHub Copilot agent definitions are not Codex skills.
- The repository's shared Home Manager configuration is the desired system-wide installation point.

## Current-System Impact

- Extends global Codex skills with the pinned official .NET skill catalog; update the Home Manager and Agent Tooling sections of `.specify/memory/current-system.md`.
