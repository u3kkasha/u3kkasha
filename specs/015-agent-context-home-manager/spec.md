# Feature Specification: Home Manager Agent Context

**Feature Branch**: `015-agent-context-home-manager`

**Created**: 2026-09-30

**Status**: Draft

**Input**: User request: Remove the unused Antigravity CLI integration, then use Home Manager to manage global instructions for remaining agent clients.

## User Scenarios & Testing

### User Story 1 - Remove unused Antigravity CLI (Priority: P1)

As the system owner, I want the unused Antigravity CLI and its Gemini configuration removed so that my managed environment only provisions agent tools I use.

**Why this priority**: Removing the unused application is the first requested step and prevents stale package and MCP configuration from remaining active.

**Independent Test**: Evaluate both supported hosts and confirm neither installs Antigravity CLI, writes its Gemini MCP configuration, nor generates Gemini global instructions.

**Acceptance Scenarios**:

1. **Given** either supported host, **When** its Home Manager configuration is evaluated, **Then** no Antigravity CLI package or program integration is enabled.
2. **Given** a generated Home Manager configuration, **When** its agent files and MCP projections are inspected, **Then** no Gemini instruction or Antigravity-specific MCP output is present.

### User Story 2 - Manage remaining global agent context (Priority: P2)

As the system owner, I want Home Manager's native context options to manage global instructions for the configured Codex and OpenCode clients so that agent context follows their supported configuration interfaces.

**Why this priority**: Native options reduce custom path management and keep the shared instruction source declarative after removing Antigravity.

**Independent Test**: Evaluate both supported hosts and confirm Codex and OpenCode receive the expected shared global instruction content from Home Manager context options.

**Acceptance Scenarios**:

1. **Given** either supported host, **When** the Home Manager configuration is evaluated, **Then** Codex and OpenCode each receive the shared instruction content as global context.
2. **Given** the shared instructions are updated, **When** Home Manager regenerates the user's configuration, **Then** both configured clients use the updated content without maintaining duplicate copies.

### Edge Cases

- Both supported hosts must generate the same Codex and OpenCode global context.
- Project-level OpenCode instructions and repository AGENTS.md remain available alongside global context.
- Agents without an enabled integration in this configuration are not added as part of this change.

## Requirements

### Functional Requirements

- **FR-001**: The managed user environment MUST no longer install or enable Antigravity CLI.
- **FR-002**: The managed user environment MUST no longer generate Gemini global instructions or Antigravity CLI MCP configuration.
- **FR-003**: The configured Codex client MUST receive the shared global instruction content through its supported Home Manager context configuration.
- **FR-004**: The configured OpenCode client MUST receive the shared global instruction content through its supported Home Manager context configuration.
- **FR-005**: The shared instruction content MUST remain a single source used by both configured clients.
- **FR-006**: Existing project-level instruction discovery and MCP integrations for remaining clients MUST continue to work.

### Key Entities

- **Shared agent context**: The single host-neutral global instruction content consumed by configured coding agents.
- **Agent client**: An enabled application whose global context is managed by the user's declarative configuration.

## Success Criteria

### Measurable Outcomes

- **SC-001**: Both supported host configurations contain zero enabled Antigravity CLI integrations and zero generated Gemini global instruction files.
- **SC-002**: Both supported hosts configure Codex and OpenCode with the same shared global instruction content.
- **SC-003**: Repository-level instruction discovery and the existing Codex/OpenCode MCP integrations remain present after the change.

## Assumptions

- Gemini instruction generation exists only to support the Antigravity CLI integration and is removed with it.
- The scope is limited to currently configured Codex and OpenCode clients; native Home Manager support for other agents does not imply adding those applications.
- The pinned Home Manager input is the source of truth for which native context options can be used.

## Current-System Impact

- **Claims to update**: Home Manager and Agent Tooling description of enabled clients, global instruction ownership, and MCP integration projections.
- **Limitations resolved or introduced**: Removes the custom Codex instruction file mapping; Gemini instructions cease to be managed because their only consumer is removed.
