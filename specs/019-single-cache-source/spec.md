# Feature Specification: Single Cache Source

**Feature Branch**: `019-single-cache-source`

**Created**: 2026-10-17

**Status**: Implemented

**Input**: User request to maintain one cache list and use it everywhere.

## User Scenarios & Testing

### User Story 1 - Keep Host Cache Settings in One Place (Priority: P1)

As a maintainer, I want one canonical list of trusted cache URLs and keys so both hosts stay aligned and cache changes cannot drift between configuration layers.

**Why this priority**: Duplicate cache declarations create inconsistent trust and availability across fresh evaluation and activated systems.

**Independent Test**: Evaluate both host configurations and confirm their substituters and keys exactly equal the canonical cache lists.

**Acceptance Scenarios**:

1. **Given** the canonical cache lists, **When** either supported host is evaluated, **Then** its daemon settings exactly match those lists, including Niri, without duplicates.
2. **Given** the Niri module is enabled, **When** system cache settings are evaluated, **Then** its separate cache declaration does not add a duplicate entry.

## Requirements

### Functional Requirements

- **FR-001**: All public cache URLs and keys MUST be declared once in the canonical internal cache source.
- **FR-002**: Both supported hosts MUST consume the canonical cache lists.
- **FR-003**: The Niri module MUST NOT add a second declaration of cache values already present canonically.
- **FR-004**: Flake metadata MUST NOT repeat cache values outside the canonical source.
- **FR-005**: Compatible direct flake inputs MUST follow the root `nixpkgs` input to avoid unnecessary locked revisions.

## Success Criteria

### Measurable Outcomes

- **SC-001**: Each cache URL and public key has one active literal declaration in the repository.
- **SC-002**: Both host cache URL and key lists match the canonical lists exactly.

## Assumptions

- Nix flake `nixConfig` requires literal values, so reusing an imported canonical list there is unavailable.
- A single source of truth is preferred over bootstrap cache hints; caches become available after NixOS activation.
- Existing trusted cache URLs and public keys remain unchanged.
