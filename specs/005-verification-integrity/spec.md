# Feature Specification: Verification Integrity

**Feature Directory**: `005-verification-integrity`

**Created**: 2026-08-13

**Status**: Draft

**Input**: "Separate fast assertions from generated configuration checks, preserve nixd dependency context where evaluation permits, and remove VM username hard-coding."

## Intent and Scope

### Problem

The check named `unit-tests` evaluates and realizes integration-sized generated Home Manager
closures, nixd discards dependency context from a locked-input path, and VM scripts duplicate
the configured username.

### Desired Outcome

Fast assertions remain genuinely cheap, generated-configuration and closure checks have
honest names and documented cost, nixd retains its locked-input dependency edge without an
unsafe context discard when evaluable, and VM tests derive user identity from the canonical
internal value.

### Out of Scope

- Reducing the contents of the actual supported Home Manager configurations.
- Replacing nixd or changing its configured option expressions.
- Executing resource-intensive VM builds locally when capacity is insufficient.

## Affected Targets

| Target or layer                  | Affected? | Expected observable change                                       |
| -------------------------------- | --------- | ---------------------------------------------------------------- |
| `nixos` host                     | Yes       | nixd generated configuration retains an explicit dependency edge |
| `nixos-wsl` host                 | Yes       | Generated closure checks remain separate and explicit            |
| Shared NixOS modules             | No        | N/A                                                              |
| Shared Home Manager modules      | Yes       | Removes unsafe nixd context discard when evaluation permits      |
| Developer shell or agent tooling | No        | N/A                                                              |
| CI, caching, or verification     | Yes       | Honest checks and canonical VM usernames                         |

## User Scenarios & Testing

### User Story 1 - Run Truly Fast Assertions (Priority: P1)

As a maintainer, I can run the quick unit target without realizing browser, graphical, or
agent-tool closures.

**Why this priority**: Misclassified checks make local feedback slow and violate verification policy.

**Independent Test**: `nix build .#unit-tests --no-link` builds only the pure assertion
derivation, while separately named generated-configuration checks cover supported host output.

**Acceptance Scenarios**:

1. **Given** a cold store, **When** the unit target is built, **Then** it does not require
   generated supported-host Home Manager closures.
2. **Given** generated configuration behavior, **When** its separate checks run, **Then**
   identity, GUI, container, MCP, and nixd assertions remain covered.

### User Story 2 - Preserve nixd Dependency Integrity (Priority: P1)

As the configured user, nixd receives locked flake inputs with their Nix dependency context
preserved so its generated configuration has an explicit closure relationship.

**Why this priority**: Discarded string context hides an otherwise necessary dependency edge.

**Independent Test**: Evaluation and the generated-configuration build pass without
`builtins.unsafeDiscardStringContext`; if a real cycle is proven, only the minimal workaround
is retained with a documented relationship and closure test.

**Acceptance Scenarios**:

1. **Given** nixd is enabled, **When** its configuration is generated, **Then** locked input
   paths resolve and their dependency closure is available.

### User Story 3 - Keep VM Identity Canonical (Priority: P2)

As a maintainer, changing the configured username in one declarative source automatically
updates VM assertions.

**Why this priority**: Hard-coded test identities can silently drift from host configuration.

**Independent Test**: Both VM scripts interpolate `lib.internal.username` and their
derivations evaluate successfully.

**Acceptance Scenarios**:

1. **Given** either VM definition, **When** its script is generated, **Then** all user paths
   and account checks use the canonical username.

### Edge Cases

- Preserving nixd string context may reveal an evaluation cycle; a workaround is acceptable
  only with reproducible evidence, minimal scope, documentation, and a closure assertion.
- Full VM execution may remain CI-only due to local CPU, memory, or time constraints.

## Requirements

### Functional Requirements

- **FR-001**: `unit-tests` MUST contain only quick assertions whose derivation does not depend
  on integration-sized supported-host Home Manager closures.
- **FR-002**: Generated-configuration and closure checks MUST be separately named and their
  expected cost MUST be documented.
- **FR-003**: Existing configuration assertions MUST remain covered by the appropriate new target.
- **FR-004**: nixd MUST preserve locked-input string context unless evaluation proves a real cycle.
- **FR-005**: Both VM scripts MUST derive usernames from `lib.internal.username`.

### Invariants

- **INV-001**: Both host builds and all existing functional assertions MUST remain valid.
- **INV-002**: State versions MUST remain unchanged.

### Security and State

- **SEC-001**: No new privilege, credential, socket, or trust boundary.
- **STATE-001**: No state migration; rollback restores previous check wiring and nixd generation.

## Success Criteria

### Measurable Outcomes

- **SC-001**: The unit, generated-configuration, and any closure checks each build under
  distinct names and are documented as quick or integration-sized.
- **SC-002**: No `unsafeDiscardStringContext` remains unless a reproducible cycle is recorded
  and covered by a closure test.
- **SC-003**: Both VM derivations evaluate and contain no literal configured username.

## Current-System Impact

- **Claims to update**: Capability Status verification, Home Manager and Agent Tooling,
  Maintenance and Verification.
- **Limitations resolved or introduced**: Resolves dishonest unit-test cost, nixd context
  discard if evaluation permits, and VM username hard-coding; introduces none unless a proven
  nixd cycle requires a documented limitation.

## Assumptions

- Pure library and source-shape assertions can be evaluated without supported host closures.
