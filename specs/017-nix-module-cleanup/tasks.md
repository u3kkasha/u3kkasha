---
description: "Nix configuration implementation tasks"
---

# Tasks: Nix Module Cleanup

**Input**: `spec.md` and `plan.md` from `specs/017-nix-module-cleanup/`

**Organization**: Tasks are grouped by independently verifiable configuration outcome.

## Phase 1: Guardrails and Baseline

**Purpose**: Record existing outputs and ensure the starting assertions pass.

- [x] T001 Run `nix build .#unit-tests .#configuration-tests --no-link` and record the baseline.
- [x] T002 Record current module argument consumers in `flake.nix`, `modules/`, and `tests/`.

**Checkpoint**: Existing unit and generated-configuration assertions pass before refactoring.

## Phase 2: User Story 1 - Keep Module Interfaces Compatible (Priority: P1)

**Goal**: Keep standard Nixpkgs `lib` intact and pass custom helpers explicitly.

**Independent Test**: `nix build .#configuration-tests --no-link` and both host builds succeed.

- [x] T003 [US1] Pass `internal` and `hm` as named arguments in `flake.nix`; migrate `lib.internal` and `lib.hm` consumers in `flake.nix`, `modules/`, `systems/x86_64-linux/`, and `tests/vm-nixos.nix` plus `tests/vm-wsl-mock.nix`.
- [x] T004 [US1] Pass standard `lib` plus the named `internal` argument into `tests/unit.nix` and `tests/configuration.nix`, then update their helper references.
- [x] T005 [US1] Run `nix build .#configuration-tests .#nixos-build .#nixos-wsl-build --no-link`.

**Checkpoint**: Both hosts evaluate with standard module-library semantics and tests keep using the same repo helpers.

## Phase 3: User Story 2 - Make Configuration Ownership Obvious (Priority: P2)

**Goal**: Separate native KDL, common utilities, and developer toolchains while preserving outputs.

**Independent Test**: Unit and configuration assertions pass, and generated Niri configuration contains the host fragment.

- [x] T006 [US2] Move the shared Niri KDL string to `modules/home/niri.kdl` and substitute `internal.niri.outputConfig` at its marker from `modules/home/niri.nix`.
- [x] T007 [US2] Move Node.js, .NET, DuckDB, `uv`, `mdr`, and Skills CLI ownership into `modules/home/devtools.nix`; retain GUI conditions and default enablement in `modules/home/default.nix`.
- [x] T008 [US2] Update the exact Home Manager module discovery list in `tests/unit.nix` for `devtools.nix` and verify package-preserving assertions in `tests/configuration.nix`.
- [ ] T009 [US2] Bind `unit-tests` and `configuration-tests` once in `flake.nix` and reuse the values in `packages` and `checks`.
- [ ] T010 [US2] Run `nix fmt -- --ci`, `nix build .#unit-tests .#configuration-tests .#nixos-build .#nixos-wsl-build --no-link`, and `nix flake check`.

**Checkpoint**: Existing output names, generated settings, and host package closures remain unchanged.

## Final Phase: Cross-Target Verification and Memory

- [ ] T011 Build `.#vm-test-nixos` and `.#vm-test-wsl-mock` in CI as runtime integration checks.
- [ ] T012 Reconcile `.specify/memory/current-system.md` through the mandatory memory-sync hook.
- [ ] T013 Run `.specify/scripts/bash/validate-project.sh` and confirm no security, state-version, or backup policy changed.

## Dependencies and Execution

- T001-T002 precede implementation.
- T003-T005 precede US2 so the module argument migration is independently evaluated.
- T006-T009 change distinct files except for `modules/home/default.nix` and `tests/unit.nix`; perform those overlapping edits sequentially.
- T010 depends on all implementation tasks; T011 may run in CI after T010 succeeds.
- T012-T013 complete the documented architecture and governance record.

## Completion Rules

- All requirements and acceptance scenarios map to T003-T013.
- Every completed task is marked `[X]`.
- No planned module or output path is left unverified.
- `$speckit-analyze` reports no unresolved critical inconsistency before implementation.
- `$speckit-converge` reports no remaining implementation gap before review.
