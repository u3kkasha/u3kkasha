# Feature Specification: Repository Hardening

**Feature Directory**: `001-repository-hardening`

**Created**: 2026-08-13

**Status**: Implemented with one operator-deferred finding

**Input**: Migrated open findings from the 2026-08-13 Nix engineering review.

## Intent and Scope

### Problem

The configuration is operational, but several security, correctness, test-cost, recovery,
and module-boundary weaknesses remain. They should be resolved through reviewed,
independently verifiable slices rather than losing the findings during the documentation
migration.

### Desired Outcome

Each accepted hardening slice removes a documented limitation without regressing either
supported host, reproducibility, declarative ownership, or recovery behavior.

### Out of Scope

- Implementing the findings as part of the Spec Kit bootstrap.
- Treating every finding as one indivisible delivery.

## Affected Targets

| Target or layer                  | Affected? | Expected observable change                                  |
| -------------------------------- | --------- | ----------------------------------------------------------- |
| `nixos` host                     | Yes       | Security, desktop correctness, and recovery improvements    |
| `nixos-wsl` host                 | Yes       | Package closure, shared settings, and recovery improvements |
| Shared NixOS modules             | Yes       | Docker, system, cache, and host-boundary hardening          |
| Shared Home Manager modules      | Yes       | Niri, Git, GUI, and nixd corrections                        |
| Developer shell or agent tooling | No        | No presently identified outcome                             |
| CI, caching, or verification     | Yes       | Honest unit/integration separation and added validation     |

## User Scenarios & Testing

### User Story 1 - Remove High-Risk Runtime Defects (Priority: P1)

As the system operator, I want privilege and session commands to match intended runtime
behavior so normal use does not silently grant unnecessary authority or invoke unavailable
tools.

**Why this priority**: These findings affect security or runtime correctness.

**Independent Test**: Focused option assertions and Niri configuration validation pass on
the affected hosts.

**Acceptance Scenarios**:

1. **Given** conventional Docker is selected as the sole container engine, **When** the
   host is evaluated, **Then** Docker and Compose work for the configured user, Podman is
   absent, and root-equivalent `docker` group access is explicitly documented and tested.
2. **Given** the Niri session resumes, **When** monitors are powered on, **Then** the
   configured command is available in that session and uses Niri's native interface.

### User Story 2 - Restore Declarative and Recoverable User Configuration (Priority: P2)

As the configured user, I want declared identity, GUI boundaries, and backups to behave
predictably across clean installations and repeated activations.

**Why this priority**: These gaps undermine declarative completeness and recovery.

**Independent Test**: Home Manager evaluation proves identity and GUI closure behavior;
activation tests or an explicit procedure prove backup retention.

**Acceptance Scenarios**:

1. **Given** a clean installation, **When** Git configuration is generated, **Then** no
   global name or email is set because identity is configured per repository.
2. **Given** GUI support is disabled, **When** the Home Manager closure is evaluated,
   **Then** GUI-only cursor assets are absent.
3. Backup rotation remains unchanged by explicit operator decision; destructive replacement
   of the single `.backup` copy remains a documented limitation rather than an acceptance
   criterion for the implemented slices.

### User Story 3 - Make Verification and Boundaries Honest (Priority: P3)

As a maintainer, I want checks and modules to reflect their real cost, dependencies, and
host scope.

**Why this priority**: Clear boundaries reduce future maintenance risk.

**Independent Test**: Pure tests stay small, integration checks cover generated closures,
and both host builds remain successful.

**Acceptance Scenarios**:

1. **Given** unit checks run from a cold store, **When** their closure is realized, **Then**
   browser and unrelated agent packages are not required.
2. **Given** host-specific display configuration, **When** shared modules are evaluated,
   **Then** physical-host settings are absent from the reusable layer.

### Edge Cases

- Docker's daemon socket and `docker` group are root-equivalent; this exposure is accepted
  to provide conventional Docker and Compose behavior without Podman compatibility layers.
- Preserving nixd dependency context may expose an evaluation cycle that requires a tested,
  documented alternative.

## Requirements

### Functional Requirements

- **FR-001**: Docker MUST be the sole container engine, with conventional Docker and Compose
  behavior and an explicit root-equivalent group-access policy.
- **FR-002**: Niri runtime commands MUST resolve to tools provided by the Niri session.
- **FR-003**: Shared Git identity MUST be applied or unused declarations MUST be removed.
- **FR-004**: Disabling GUI configuration MUST exclude GUI-only cursor assets.
- **FR-005**: Activation backup behavior SHOULD preserve a recoverable previous copy; this
  requirement is intentionally deferred by the operator and remains a known limitation.
- **FR-006**: Quick unit checks MUST be separated from integration-sized closure checks.
- **FR-007**: nixd's locked-input dependency edge MUST be explicit or documented and tested.
- **FR-008**: Physical-host settings MUST live in the relevant host configuration.
- **FR-009**: Cache declarations, unfree policy, and VM identity SHOULD avoid unnecessary
  duplication or hard-coding.

### Invariants

- **INV-001**: Both supported host configurations MUST continue to build.
- **INV-002**: Docker MUST be the only container engine, superseding the original Podman
  invariant by explicit operator decision on 2026-08-13.
- **INV-003**: State versions MUST remain unchanged.

### Security and State

- **SEC-001**: Root-equivalent socket and group access MUST be explicitly minimized or
  accepted with documented verification.
- **STATE-001**: Any future backup change MUST include a recovery and rollback procedure.

## Success Criteria

### Measurable Outcomes

- **SC-001**: Every implemented slice has a focused passing assertion or runtime validation.
- **SC-002**: Both host builds pass after every shared-layer slice.
- **SC-003**: Resolved limitations are removed from current-system memory only after their
  acceptance evidence passes.

## Current-System Impact

- **Claims to update**: Capability matrix, architecture, security, verification, and known
  limitations as individual slices are implemented.
- **Limitations resolved or introduced**: The corresponding items in
  `.specify/memory/current-system.md`; destructive single-backup replacement remains by
  explicit operator decision.

## Assumptions

- The findings may be split into separate feature specifications before planning.
- CI remains responsible for resource-intensive VM validation.
