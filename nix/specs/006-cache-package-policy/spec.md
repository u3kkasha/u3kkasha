# Feature Specification: Cache and Package Policy

**Feature Directory**: `006-cache-package-policy`

**Created**: 2026-08-13

**Status**: Draft

**Input**: "Deduplicate cache URLs and keys and replace broad unfree allowance with the narrowest practical predicate."

## Intent and Scope

### Problem

The same cache endpoints and signing keys are duplicated in flake and NixOS configuration,
while supported hosts and VM test package sets broadly allow every unfree package.

### Desired Outcome

Cache metadata has one declarative source consumed by both supported hosts' daemon
configuration, and unfree evaluation is restricted to the exact package names required by
supported hosts and tests.

### Out of Scope

- Adding, removing, or rotating cache endpoints or signing keys.
- Replacing currently selected packages merely because they are unfree.
- Changing CI cache-push credentials or destinations.

## Affected Targets

| Target or layer                  | Affected? | Expected observable change                              |
| -------------------------------- | --------- | ------------------------------------------------------- |
| `nixos` host                     | Yes       | Uses the shared cache metadata and narrow unfree policy |
| `nixos-wsl` host                 | Yes       | Uses the shared cache metadata and narrow unfree policy |
| Shared NixOS modules             | Yes       | Consumes canonical cache values                         |
| Shared Home Manager modules      | No        | N/A                                                     |
| Developer shell or agent tooling | No        | N/A                                                     |
| CI, caching, or verification     | Yes       | VM package sets use the same narrow predicate           |

## User Scenarios & Testing

### User Story 1 - Maintain Cache Metadata Once (Priority: P1)

As a maintainer, I can update each cache URL or public key in one declarative source and
have both NixOS daemons receive the same ordered values.

**Why this priority**: Duplicated trust metadata can drift and create inconsistent evaluation.

**Independent Test**: Assertions compare flake `nixConfig` and both hosts' daemon settings to
the canonical internal cache lists.

**Acceptance Scenarios**:

1. **Given** canonical cache metadata, **When** host configurations are evaluated, **Then**
   both consumers expose the same URL and key lists without duplicate literals.

### User Story 2 - Permit Only Required Unfree Packages (Priority: P1)

As the operator, supported configurations evaluate their required packages without granting
blanket permission to unrelated unfree software.

**Why this priority**: Unfree-package allowances are a governed policy boundary.

**Independent Test**: Both host builds and VM derivations evaluate under an exact allowlist,
and a focused assertion rejects an unrelated unfree package name.

**Acceptance Scenarios**:

1. **Given** a package required by a supported host, **When** its license is unfree, **Then**
   the predicate permits its exact package name.
2. **Given** any unrelated unfree package, **When** the predicate is evaluated, **Then** it is rejected.

### Edge Cases

- Wrapped or renamed packages must be matched using the stable package name observed during
  evaluation rather than an overly broad prefix.
- VM test imports must use the same policy source as supported host imports.

## Requirements

### Functional Requirements

- **FR-001**: Cache URLs and trusted public keys MUST each have one declarative source.
- **FR-002**: Both hosts' Nix daemon settings MUST consume the canonical lists.
- **FR-003**: Broad `allowUnfree = true` MUST be replaced by the narrowest practical exact-name predicate.
- **FR-004**: Host and VM package imports MUST share the same unfree policy.

### Invariants

- **INV-001**: Existing cache endpoints and keys MUST remain unchanged and ordered.
- **INV-002**: Both host builds and VM derivations MUST continue to evaluate.
- **INV-003**: State versions MUST remain unchanged.

### Security and State

- **SEC-001**: Trust metadata remains public and unchanged; unfree permission is narrowed.
- **STATE-001**: No state migration; rollback restores the prior duplicated declarations.

## Success Criteria

### Measurable Outcomes

- **SC-001**: Repository search finds each cache URL and public key literal in exactly one
  declarative source outside historical feature records.
- **SC-002**: No active configuration contains `allowUnfree = true`.
- **SC-003**: Focused assertions, both host builds, and both VM derivation evaluations pass.

## Current-System Impact

- **Claims to update**: Module Discovery and Internal Values, Configuration, Caching, and
  Trust, Maintenance and Verification.
- **Limitations resolved or introduced**: Resolves cache duplication and broad unfree policy;
  introduces none.

## Assumptions

- The exact allowlist can be derived from currently selected package evaluation failures and metadata.
