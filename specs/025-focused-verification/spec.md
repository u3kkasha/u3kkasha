# Feature Specification: Focused Verification

**Feature Directory**: `025-focused-verification`

**Created**: 2026-11-18

**Status**: Draft

**Input**: Remove low-value configuration assertions and resolve the nixd-related CI failure with a focused verification design.

Before completing this specification, read `.specify/memory/constitution.md` and
`.specify/memory/current-system.md`. Describe desired behavior, not implementation.

## Intent and Scope

### Problem

The configuration verification target includes assertions that merely restate selected
option values or package membership, while its nixd assertion forces generated JSON into
Nix evaluation and causes `nix flake check` to fail on a store-path reference.

### Desired Outcome

Verification remains focused on repository policies, reproducibility, generated behavior,
and runtime outcomes. Routine configuration evaluation no longer fails because a test
parses nixd JSON containing locked-input store paths.

### Out of Scope

- Changing configured host behavior, packages, or persistent state.
- Reworking the nixd configuration format or locked-input lookup design.
- Weakening security, module-discovery, or runtime integration checks.

## Affected Targets

| Target or layer                  | Affected? | Expected observable change                                                      |
| -------------------------------- | --------- | ------------------------------------------------------------------------------- |
| `nixos` host                     | No        | No host behavior change                                                         |
| `nixos-wsl` host                 | No        | No host behavior change                                                         |
| Shared NixOS modules             | No        | No module behavior change                                                       |
| Shared Home Manager modules      | No        | No runtime behavior change                                                      |
| Developer shell or agent tooling | No        | No change                                                                       |
| CI, caching, or verification     | Yes       | Remove low-signal assertions and stop forcing nixd JSON through evaluator tests |

## User Scenarios & Testing

### User Story 1 - Reliable Configuration Verification (Priority: P1)

The operator can run the repository's flake checks without a false failure caused by a
test inspecting nixd's serialized store paths.

**Why this priority**: CI must report actual configuration regressions rather than test
implementation artifacts.

**Independent Test**: Run the focused configuration check and confirm it evaluates both
hosts and the retained policy assertions without parsing nixd JSON in the evaluator.

**Acceptance Scenarios**:

1. **Given** both host configurations, **When** configuration verification runs,
   **Then** retained policy assertions complete without a nixd store-path serialization error.
2. **Given** the nixd module remains enabled, **When** a host configuration is built,
   **Then** nixd's generated configuration and locked-input closure remain part of the host output.

### User Story 2 - High-Signal Test Suite (Priority: P2)

The operator can identify which tests protect explicit policy, generated behavior, or
runtime behavior, without routine checks that only confirm a directly assigned value.

**Why this priority**: Smaller, meaningful checks reduce maintenance and avoid coupling
tests to incidental module representation.

**Independent Test**: Review retained checks against explicit repository invariants and
run the relevant lightweight and runtime verification targets.

**Acceptance Scenarios**:

1. **Given** repository security and reproducibility policies, **When** a policy regresses,
   **Then** an assertion or runtime test detects it.
2. **Given** a setting that is directly declared without a behavioral invariant,
   **When** the suite is maintained, **Then** no redundant assertion exists solely to
   confirm that declaration.

### Edge Cases

- nixd's generated JSON may contain absolute paths in the Nix store; test evaluation must
  not deserialize those paths as evaluator-level plain strings.
- Removal of weak assertions must retain coverage for both hosts' security and runtime
  boundaries.

## Requirements

### Functional Requirements

- **FR-001**: Configuration verification MUST cover explicit security, trust, cache,
  reproducibility, and host-boundary policies.
- **FR-002**: Configuration verification MUST NOT force nixd JSON into evaluator-level
  assertions solely to inspect its string layout.
- **FR-003**: The nixd module MUST continue to generate its configuration and include the
  locked-input paths in the resulting host closure.
- **FR-004**: Assertions that only confirm directly assigned host labels, package presence,
  simple enable flags, or duplicated option values MUST be removed unless they protect a
  documented invariant or observable behavior.
- **FR-005**: Runtime VM checks MUST retain coverage for Docker service availability and
  configured-user access on both supported targets.

### Invariants

- **INV-001**: Exact module-discovery checks remain aligned with the constitution.
- **INV-002**: Unfree package allowance, trusted users, cache policy, and local MCP command
  reproducibility remain covered.
- **INV-003**: Neither host's runtime configuration changes as part of this feature.

### Security and State

- **SEC-001**: No privilege or credential boundary changes.
- **STATE-001**: No persistent state or state-version change.

## Success Criteria

### Measurable Outcomes

- **SC-001**: The configuration check no longer fails with the nixd JSON store-path
  reference error.
- **SC-002**: Every retained configuration assertion maps to a documented invariant,
  generated behavior, or security/reproducibility property.
- **SC-003**: Both VM tests retain Docker daemon and configured-user access coverage.

## Current-System Impact

- **Claims to update**: Maintenance and Verification section: describe the narrower
  configuration assertion scope and remove nixd JSON string-layout assertion coverage.
- **Limitations resolved or introduced**: Resolve the CI failure caused by the nixd
  assertion's evaluator-level JSON parsing.

## Assumptions

- The nixd generated configuration is already owned by the Home Manager module and does
  not require a separate test of its serialized string representation.
- Host builds and VM checks remain the appropriate validation for generated host outputs
  and runtime behavior.
