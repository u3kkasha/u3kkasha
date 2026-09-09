# Feature Specification: [FEATURE NAME]

**Feature Directory**: `[###-feature-name]`

**Created**: [DATE]

**Status**: Draft

**Input**: "$ARGUMENTS"

Before completing this specification, read `.specify/memory/constitution.md` and
`.specify/memory/current-system.md`. Describe desired behavior, not implementation.

## Intent and Scope _(mandatory)_

### Problem

[What is wrong, missing, unsafe, or unnecessarily difficult in the current system?]

### Desired Outcome

[What observable configuration or operational outcome should be true when complete?]

### Out of Scope

- [Explicitly excluded behavior]

## Affected Targets _(mandatory)_

| Target or layer                  | Affected? | Expected observable change |
| -------------------------------- | --------- | -------------------------- |
| `nixos` host                     | Yes/No    | [Outcome or N/A]           |
| `nixos-wsl` host                 | Yes/No    | [Outcome or N/A]           |
| Shared NixOS modules             | Yes/No    | [Outcome or N/A]           |
| Shared Home Manager modules      | Yes/No    | [Outcome or N/A]           |
| Developer shell or agent tooling | Yes/No    | [Outcome or N/A]           |
| CI, caching, or verification     | Yes/No    | [Outcome or N/A]           |

## User Scenarios & Testing _(mandatory)_

Treat the operator, configured user, and downstream project as the relevant users. Each
story represents an independently verifiable configuration outcome.

### User Story 1 - [Primary Configuration Outcome] (Priority: P1)

[Describe the most important outcome in plain language.]

**Why this priority**: [Why it is essential.]

**Independent Test**: [Exact evaluation, build, VM, or runtime observation that proves it.]

**Acceptance Scenarios**:

1. **Given** [current configuration], **When** [evaluation/application/runtime action],
   **Then** [observable result].

### User Story 2 - [Secondary Outcome] (Priority: P2)

[Remove this story if the feature has only one independently useful outcome.]

**Why this priority**: [Reason.]

**Independent Test**: [Verification.]

**Acceptance Scenarios**:

1. **Given** [state], **When** [action], **Then** [result].

### Edge Cases

- [Unsupported host, disabled option, evaluation failure, missing credential, or state boundary]

## Requirements _(mandatory)_

### Functional Requirements

- **FR-001**: The configuration MUST [testable behavior].
- **FR-002**: The affected target MUST [testable behavior].

### Invariants

- **INV-001**: [Existing behavior or constitutional constraint that MUST remain true.]

### Security and State

- **SEC-001**: [Privilege, credential, trust, secret, socket, or unfree-package effect, or N/A.]
- **STATE-001**: [Persistent-state, migration, backup, rollback, or stateVersion effect, or N/A.]

## Success Criteria _(mandatory)_

### Measurable Outcomes

- **SC-001**: [A command or observation proves the primary outcome.]
- **SC-002**: [Unaffected target or invariant continues to pass.]

## Current-System Impact _(mandatory)_

Identify claims in `.specify/memory/current-system.md` that will change after successful
implementation. Write `None` only when the feature has no effect on implemented
architecture, capability status, supported workflows, policies, verification, or known
limitations.

- **Claims to update**: [Sections and claims, or None]
- **Limitations resolved or introduced**: [Items, or None]

## Assumptions

- [Reasonable default or dependency used to bound the feature]
