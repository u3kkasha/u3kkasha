# Feature Specification: Repository-Local Git Identity

**Feature Directory**: `004-git-identity`

**Created**: 2026-08-13

**Status**: Draft

**Input**: "Remove shared Git name and email settings; identity is configured per repository instead."

## Intent and Scope

### Problem

The internal library declares a personal name and email that the generated Git configuration
does not use. Keeping unused global identity values implies an ownership policy the operator
does not want and risks later applying personal identity too broadly.

### Desired Outcome

The shared internal library declares no Git name or email, Home Manager generates no global
Git identity, and repositories remain responsible for their own identity settings.

### Out of Scope

- Choosing or generating per-repository identities.
- Modifying existing repository-local `.git/config` files.

## Affected Targets

| Target or layer                  | Affected? | Expected observable change                      |
| -------------------------------- | --------- | ----------------------------------------------- |
| `nixos` host                     | Yes       | Global Git config remains identity-free         |
| `nixos-wsl` host                 | Yes       | Global Git config remains identity-free         |
| Shared NixOS modules             | No        | N/A                                             |
| Shared Home Manager modules      | Yes       | Makes repository-local identity policy explicit |
| Developer shell or agent tooling | No        | N/A                                             |
| CI, caching, or verification     | Yes       | Assertions reject shared/global identity values |

## User Scenarios & Testing

### User Story 1 - Choose Identity Per Repository (Priority: P1)

As the configured user, I can select an appropriate Git identity in each repository without
a personal identity being declared or applied globally by this configuration.

**Why this priority**: Repository-specific identities avoid accidental attribution across contexts.

**Independent Test**: Evaluation proves the internal library has no `name` or `email` fields
and both generated Git configurations contain no `user.name` or `user.email`.

**Acceptance Scenarios**:

1. **Given** either supported host, **When** Home Manager generates Git settings, **Then** no
   global Git name or email is present.
2. **Given** the internal shared values, **When** evaluated, **Then** no personal name or email
   declaration exists.

### Edge Cases

- Git commits in repositories without local or conditional identity configuration will fail
  with Git's normal missing-identity message; this is intentional.

## Requirements

### Functional Requirements

- **FR-001**: Shared internal values MUST NOT declare a personal Git name or email.
- **FR-002**: Generated global Git configuration MUST NOT set `user.name` or `user.email` on
  either supported host.
- **FR-003**: Existing non-identity Git settings MUST remain unchanged.

### Invariants

- **INV-001**: Git, GitHub CLI, lazygit, and difftastic configurations MUST remain enabled.
- **INV-002**: Both state versions MUST remain unchanged.

### Security and State

- **SEC-001**: Removing globally declared personal data narrows configuration exposure.
- **STATE-001**: Existing repository-local Git configuration is untouched; rollback is the
  previous generation.

## Success Criteria

### Measurable Outcomes

- **SC-001**: Focused assertions pass for the absence of shared and global Git identity.
- **SC-002**: Both supported host evaluations continue to pass with existing Git behavior.

## Current-System Impact

- **Claims to update**: Module Discovery and Internal Values, Home Manager and Agent Tooling.
- **Limitations resolved or introduced**: Resolves the unused Git identity declaration
  limitation and documents repository-local ownership; introduces none.

## Assumptions

- The operator will configure Git identity within each repository when commits are needed.
