# Feature Specification: Repository-Owned Test Contracts

**Feature Branch**: `026-repository-owned-test-contracts`
**Created**: 2026-11-18
**Status**: Draft
**Input**: User description: Add durable, extensible tests for critical behavior owned by this repository; do not test Nix or upstream libraries, and refactor existing tests that are tightly coupled to incidental configuration details.

## User Scenarios & Testing

### User Story 1 - Durable module discovery coverage (Priority: P1)

The maintainer can change the set of Home Manager or NixOS modules without updating a snapshot of every discovered path, while regressions in the repository's discovery rules are still caught.

**Why this priority**: The existing full-list assertions make routine module additions require assertion maintenance and test an incidental inventory rather than the discovery behavior.

**Independent Test**: Run a focused unit check against a small fixture containing eligible and ineligible entries, then add a new eligible fixture entry and confirm it is discovered without changing expected lists.

**Acceptance Scenarios**:

1. **Given** a directory with regular `.nix` files, `default.nix`, non-Nix files, and subdirectories with and without `default.nix`, **When** the repository discovery helper runs, **Then** it returns only eligible files and directories.
2. **Given** the fixture gains another eligible module, **When** the discovery test runs, **Then** it passes without enumerating the entire fixture inventory.

### User Story 2 - Protect repository-owned generated behavior (Priority: P1)

The maintainer can change Codex merge and shell token-wrapper implementation details while tests continue to protect user-data preservation, token scoping, argument forwarding, and safe fallback behavior.

**Why this priority**: These behaviors handle user configuration and credentials, where regressions can cause data loss or expose credentials beyond the intended child process.

**Independent Test**: Run focused behavior checks using temporary files and stub executables; no network access or real GitHub credentials are needed.

**Acceptance Scenarios**:

1. **Given** user-owned Codex settings and stale managed MCP entries, **When** managed settings are merged, **Then** unrelated user settings remain, managed entries match the base configuration, and stale entries are removed.
2. **Given** a successful token lookup, **When** the shell wrapper invokes Nix, **Then** the token is scoped to that child invocation, existing configuration and arguments are preserved, and the caller environment is unchanged.
3. **Given** failed or empty token lookup, **When** the shell wrapper invokes Nix, **Then** Nix runs with the original environment and arguments without token injection.

### User Story 3 - Keep explicit security and runtime boundaries (Priority: P2)

The maintainer can change ordinary module details while checks continue to enforce explicit cache, trust, unfree-package, local MCP reproducibility, and configured-user Docker policies.

**Why this priority**: These are deliberate security, reproducibility, and operational contracts that should fail when policy changes accidentally.

**Independent Test**: Run internal policy assertions, dynamic host configuration checks, and the existing two-host Docker VM checks.

**Acceptance Scenarios**:

1. **Given** either supported host configuration, **When** policy verification runs, **Then** explicit trust and cache policies and all-local-command reproducibility are checked without snapshotting unrelated options.
2. **Given** either VM target, **When** the runtime check runs, **Then** the configured user can use the configured Docker service.

### Edge Cases

- A module directory without `default.nix` is ignored, while a newly added eligible module is accepted automatically.
- A generated Codex base without an MCP section removes stale managed entries without changing unrelated settings.
- Malformed merge input must fail before replacing the user-owned current file.
- A token command that exits unsuccessfully or returns whitespace-only output must not inject a credential.
- Existing `NIX_CONFIG` content and arbitrary Nix arguments must survive successful and fallback wrapper paths.

## Requirements

### Functional Requirements

- **FR-001**: Discovery tests MUST verify the helper's inclusion and exclusion rules using a purpose-built fixture rather than a full repository path snapshot.
- **FR-002**: Discovery tests MUST allow additional eligible fixture modules without changing a fixed expected inventory.
- **FR-003**: Codex merge tests MUST verify user-owned settings survive, managed MCP entries replace stale entries, and absence of managed MCP entries removes stale managed state.
- **FR-004**: Codex merge tests MUST verify malformed input does not replace or corrupt the current user file.
- **FR-005**: Bash and Nushell token-wrapper tests MUST cover token success, missing or failed token lookup, preservation of existing Nix configuration, argument forwarding, and process-scoped credential injection.
- **FR-006**: Policy tests MUST retain explicit checks for the exact unfree allowlist, per-host trusted users, cache policy, and dynamically all local MCP commands using reproducible store paths.
- **FR-007**: Runtime VM checks MUST retain configured-user Docker access on both supported host targets.
- **FR-008**: Tests MUST focus on repository-owned behavior and MUST NOT assert upstream library or Nix implementation behavior, full generated option inventories, or incidental serialized layouts.
- **FR-009**: The constitution MUST state the discovery-test contract and permit fixture-based behavioral coverage instead of exact full discovered-path snapshots.

## Assumptions

- Tests may use temporary files and stub executables to isolate repository-owned scripts from network access and credentials.
- The existing configuration evaluation and VM derivations remain the means to check generated host composition and runtime behavior.
- Upstream shell interpreters, TOML libraries, Nix evaluation semantics, and Docker internals are dependencies, not test subjects.

## Success Criteria

### Measurable Outcomes

- **SC-001**: Adding an eligible module fixture entry requires no edit to an expected complete module list.
- **SC-002**: A regression in each specified Codex merge or credential-scoping behavior causes a focused repository check to fail.
- **SC-003**: Every retained configuration assertion maps to an explicit policy or observable repository-owned behavior.
- **SC-004**: Both existing Docker VM targets continue to verify configured-user access.
- **SC-005**: Focused behavior checks contact no external services, require no real credentials, and make no assertions about upstream implementation details.
