# Tasks: Verification Integrity

**Input**: `spec.md` and `plan.md` from `specs/005-verification-integrity/`

## Phase 1: Guardrails and Baseline

- [x] T001 Record current `unit-tests` inputs/closure, nixd context discard, and VM username literals from `flake.nix`, `tests/unit.nix`, `modules/home/nixd.nix`, and `tests/vm-*.nix`
- [x] T002 Add source-shape assertions for safe nixd context and canonical VM usernames in `tests/unit.nix`

## Phase 2: User Story 1 - Run Truly Fast Assertions

- [x] T003 [US1] Restrict quick assertions to internal/source behavior in `tests/unit.nix`
- [x] T004 [US1] Move evaluated host, generated file, closure, and Codex merge assertions to new `tests/configuration.nix`
- [x] T005 [US1] Expose and document separate `unit-tests` and `configuration-tests` packages/checks in `flake.nix` and `.specify/memory/current-system.md`

## Phase 3: User Story 2 - Preserve nixd Dependency Integrity

- [x] T006 [US2] Remove `builtins.unsafeDiscardStringContext` from `modules/home/nixd.nix`
- [x] T007 [US2] Evaluate/build `.#configuration-tests`, `.#nixos-build`, and `.#nixos-wsl-build`; document only reproducible cycle evidence if a fallback is required

## Phase 4: User Story 3 - Keep VM Identity Canonical

- [x] T008 [US3] Interpolate `specialArgs.lib.internal.username` in `tests/vm-nixos.nix` and `tests/vm-wsl-mock.nix`
- [x] T009 [US3] Evaluate both VM derivations and confirm no literal configured username remains in active VM source

## Final Phase: Cross-Target Verification and Memory

- [x] T010 Run `nix fmt`, both separated checks, and `nix flake check --no-build`
- [x] T011 Run both host builds and run both VM builds when feasible or record CI deferral
- [x] T012 Reconcile verification and nixd claims in `.specify/memory/current-system.md`
- [x] T013 Run `.specify/scripts/bash/validate-project.sh`

## Dependencies and Execution

- T001-T002 precede T003-T009; T003 precedes T004-T005; T006 precedes T007; final tasks follow all stories.

## Completion Rules

- All requirements and invariants map to tasks with exact paths or commands.
