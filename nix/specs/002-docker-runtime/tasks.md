# Tasks: Docker Runtime

**Input**: `spec.md` and `plan.md` from `specs/002-docker-runtime/`

## Phase 1: Guardrails and Baseline

- [x] T001 Record baseline Podman/Docker option, group, discovery, and VM behavior from `tests/unit.nix`, `tests/vm-nixos.nix`, and `tests/vm-wsl-mock.nix`
- [x] T002 [US1] Add Docker-enabled, Compose, Podman-absent, exact-group, and discovery assertions in `tests/configuration.nix` and `tests/unit.nix`

## Phase 2: User Story 1 - Run Docker Workloads Directly

- [x] T003 [US1] Replace `modules/nixos/podman/default.nix` with `modules/nixos/docker/default.nix` enabling rootful Docker
- [x] T004 [US1] Replace Podman host flags in `systems/x86_64-linux/nixos/default.nix` and `systems/x86_64-linux/nixos-wsl/default.nix`
- [x] T005 [US1] Replace conditional `podman` group membership with `docker` in `modules/nixos/system/default.nix`
- [x] T006 [US1] Update Docker Engine and Compose runtime checks using `lib.internal.username` in `tests/vm-nixos.nix` and `tests/vm-wsl-mock.nix`
- [x] T007 [US1] Run `nix build .#unit-tests .#configuration-tests --no-link`

## Final Phase: Cross-Target Verification and Memory

- [x] T008 Run `nix fmt` and `nix flake check --no-build`
- [x] T009 Run `nix build .#nixos-build .#nixos-wsl-build --no-link`
- [x] T010 Run `nix build .#vm-test-nixos .#vm-test-wsl-mock` when feasible, otherwise prove both derivations evaluate and record CI deferral
- [x] T011 Confirm the accepted root-equivalent Docker group boundary, manual Podman-state migration, and unchanged state versions
- [x] T012 Reconcile `.specify/memory/current-system.md` with Docker capability and security evidence
- [x] T013 Run `.specify/scripts/bash/validate-project.sh`

## Dependencies and Execution

- T001 and T002 precede T003-T006; T003 precedes discovery-list completion in T002.
- T007 precedes T008-T013. Memory reconciliation follows verified implementation.

## Completion Rules

- All tasks use the required checkbox/ID/story/path format and map all requirements and invariants.
