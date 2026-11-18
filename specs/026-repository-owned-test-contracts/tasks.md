---
description: "Nix configuration implementation tasks"
---

# Tasks: Repository-Owned Test Contracts

**Input**: `spec.md`, `plan.md`, `research.md`, and `quickstart.md` from this feature.

## Phase 1: Guardrails

**Purpose**: Establish the discovery policy before replacing its current test.

- [x] T001 Amend Constitution II to require deterministic `scanPaths` contract tests rather than complete exact-list snapshots in `.specify/memory/constitution.md`.
- [x] T002 Add discovery fixture entries for eligible Nix files and directories, `default.nix`, non-Nix files, and directories without a default module under `tests/fixtures/scan-paths/`.

## Phase 2: User Story 1 - Durable Module Discovery (Priority: P1)

**Goal**: Verify `scanPaths` inclusion and exclusion behavior without snapshotting live module inventories.

**Independent Test**: `nix build .#unit-tests --no-link` passes with predicate checks against the fixture.

- [x] T003 [US1] Replace the Home Manager and NixOS exact path snapshots with fixture-based rule assertions in `tests/unit.nix`.
- [x] T004 [US1] Build the focused unit target with `nix build .#unit-tests --no-link`.

## Phase 3: User Story 2 - Repository-Owned Generated Behavior (Priority: P1)

**Goal**: Verify Codex merge and token wrapper behavior through observable outcomes with temporary files and stub commands.

**Independent Test**: `nix build .#configuration-tests .#token-wrapper-tests --no-link` passes without external credentials or network access.

- [x] T005 [P] [US2] Move the Bash GitHub-token `nix` wrapper into a sourceable repository file and load it from `modules/home/bash.nix`.
- [x] T006 [P] [US2] Move the Nushell GitHub-token `nix` wrapper into a sourceable repository file and load it from `modules/home/nushell.nix`.
- [x] T007 [US2] Add `tests/test_codex_merge.py` scenarios, run from `tests/configuration.nix`, for preserving user settings, managed entry replacement/removal, and malformed-input safety.
- [x] T008 [US2] Add stub `gh` and `nix` behavior checks for token success, empty/failed lookup, existing `NIX_CONFIG`, argument forwarding, and caller environment preservation in `tests/token-wrapper.nix`.
- [x] T009 [US2] Expose the token wrapper derivation as a package and flake check in `flake.nix`, categorized as a focused behavior check.
- [x] T010 [US2] Build the focused behavior targets with `nix build .#configuration-tests .#token-wrapper-tests --no-link`.

## Phase 4: User Story 3 - Security and Runtime Boundaries (Priority: P2)

**Goal**: Retain explicit trust, cache, unfree, MCP reproducibility, and Docker access coverage.

**Independent Test**: Existing policy checks and both Docker VM test derivations remain present and pass in the appropriate local or CI environment.

- [x] T011 [US3] Review `tests/unit.nix` and `tests/configuration.nix` to retain only exact unfree, trusted-user, cache, and dynamic local MCP command policies alongside generated behavior.
- [x] T012 [US3] Preserve configured-user Docker daemon access and remove the Compose version presence checks in `tests/vm-nixos.nix` and `tests/vm-wsl-mock.nix`.

## Final Phase: Documentation and Verification

- [x] T013 Update the verification claims in `.specify/memory/current-system.md` to match the new discovery, merge, wrapper, and policy checks.
- [x] T014 Run `nix build .#checks.x86_64-linux.formatting --no-link` and `.specify/scripts/bash/validate-project.sh`.
- [x] T015 Run `nix build .#unit-tests .#configuration-tests .#token-wrapper-tests --no-link`.
- [x] T016 Delegate both host builds and VM derivations to CI after the combined local build exceeded ten minutes; record this in `specs/026-repository-owned-test-contracts/quickstart.md`.
- [x] T017 Run `$speckit.system-memory.sync` for this feature and mark memory reconciliation complete after comparing source and verification evidence.
- [x] T018 Converge review found no remaining implementation gaps; host and VM verification is delegated to CI as recorded in `quickstart.md`.

## Dependencies

- T001 precedes T003 so the test change follows the amended governing policy.
- T002 precedes T003.
- T005 and T006 can run independently; T008 depends on their source boundaries and stubs.
- T007 is independent of T005/T006; T009 depends on T008.
- T011 and T012 are preservation reviews and can proceed alongside US2 implementation.
- T013-T018 follow implementation and focused verification.

## Completion Rules

- Every functional requirement and acceptance scenario maps to one or more tasks.
- All tasks are marked `[X]` after completion.
- Focused tests do not use real credentials, network services, or assertions about third-party internals.
- Host and VM checks remain categorized according to their evaluation and runtime cost.
