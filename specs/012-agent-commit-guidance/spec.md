# Feature Specification: Agent Commit Guidance

**Feature Directory**: `012-agent-commit-guidance`
**Created**: 2026-09-21
**Status**: Draft
**Input**: "Add mention that agents should commit frequently at appropriate stages and must use Conventional Commit format."

## Intent and Scope

### Problem

The shared agent instructions do not state when agents should checkpoint work or how
commit messages must be formatted.

### Desired Outcome

Codex and Gemini are instructed to commit at appropriate milestones, keep commits
focused, and always use Conventional Commits formatting.

### Out of Scope

- Automatically committing changes or changing Git hooks and repository policy.

## Affected Targets

| Target or layer                  | Affected? | Expected observable change                  |
| -------------------------------- | --------- | ------------------------------------------- |
| `nixos` host                     | Yes       | Shared guidance includes commit policy      |
| `nixos-wsl` host                 | Yes       | Shared guidance includes commit policy      |
| Shared NixOS modules             | No        | N/A                                         |
| Shared Home Manager modules      | Yes       | Instruction payload changes                 |
| Developer shell or agent tooling | Yes       | Agents receive commit guidance              |
| CI, caching, or verification     | Yes       | Configuration assertion covers the guidance |

## User Scenarios & Testing

### User Story 1 - Frequent Conventional Commits (Priority: P1)

As the repository operator, I want agents to checkpoint coherent work regularly with
consistently structured messages.

**Why this priority**: Focused, standardized commits improve review and recovery.

**Independent Test**: Configuration tests verify the shared payload includes both the
milestone-frequency rule and the Conventional Commits requirement.

**Acceptance Scenarios**:

1. **Given** either supported host, **When** an agent reads its global instructions,
   **Then** it is told to commit at appropriate milestones and use Conventional Commits.

### Edge Cases

- The guidance does not authorize committing unrelated user changes.

## Requirements

### Functional Requirements

- **FR-001**: Shared instructions MUST direct agents to commit frequently at appropriate milestones.
- **FR-002**: Shared instructions MUST direct agents to keep commits focused.
- **FR-003**: Shared instructions MUST require Conventional Commits formatting.

### Invariants

- **INV-001**: Codex and Gemini instructions MUST remain identical across both hosts.

### Security and State

- **SEC-001**: No privilege, credential, trust, or secret behavior changes.
- **STATE-001**: No state-version or migration change.

## Success Criteria

### Measurable Outcomes

- **SC-001**: Configuration tests prove all three commit-guidance requirements are present.
- **SC-002**: Existing identical-file assertions continue to pass for both hosts.

## Current-System Impact

- **Claims to update**: None; ownership and architecture are unchanged.
- **Limitations resolved or introduced**: None.

## Assumptions

- “Frequently” means at coherent milestones, not after every file edit.
