# Tasks: Cache and Package Policy

**Input**: `spec.md` and `plan.md` from `specs/006-cache-package-policy/`

## Phase 1: Guardrails and Baseline

- [x] T001 Record duplicated cache literals and broad unfree declarations from `flake.nix` and `modules/nixos/system/default.nix`
- [x] T002 Add canonical-list, consumer-equality, exact-predicate, and unrelated-package rejection assertions in `tests/unit.nix` and `tests/configuration.nix`

## Phase 2: User Story 1 - Maintain Cache Metadata Once

- [x] T003 [US1] Add canonical cache URL and public-key lists to `lib/internal/cache.nix` and project them from `lib/internal/default.nix`
- [x] T004 [US1] Remove duplicate flake `nixConfig` cache metadata and consume canonical lists in `modules/nixos/system/default.nix`
- [x] T005 [US1] Verify each active cache literal has one source and all consumers are equal using focused assertions and repository search

## Phase 3: User Story 2 - Permit Only Required Unfree Packages

- [x] T006 [US2] Add exact Steam-family names and shared `allowUnfreePredicate` to `lib/internal/default.nix`
- [x] T007 [US2] Replace all four broad unfree declarations in `flake.nix` with the shared predicate
- [x] T008 [US2] Build both hosts and evaluate both VM derivations to prove the exact allowlist is sufficient

## Final Phase: Cross-Target Verification and Memory

- [x] T009 Run `nix fmt`, both separated checks, and `nix flake check --no-build`
- [x] T010 Confirm cache order, trust values, state versions, and unrelated unfree rejection
- [x] T011 Reconcile cache/internal-value/unfree claims in `.specify/memory/current-system.md`
- [x] T012 Run `.specify/scripts/bash/validate-project.sh`

## Dependencies and Execution

- T001-T002 precede T003-T008; T003 precedes T004-T005; T006 precedes T007-T008; final tasks follow.

## Completion Rules

- All requirements and invariants map to tasks with exact paths or commands.
