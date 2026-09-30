# Tasks: Replace Flox with devenv

**Input**: `spec.md` and `plan.md` from `specs/014-flox-to-devenv/`

## Phase 1: Baseline

- [x] T001 Confirm the three Flox commits are absent from local history and the existing
      flake shell is unchanged.

## Phase 2: User Story 1 - Use devenv from either configured host

**Goal**: Install devenv for the configured user through shared Home Manager.

**Independent Test**: Both host package lists include devenv.

- [x] T002 [US1] Add `pkgs.devenv` to `modules/home/cli.nix` under the existing CLI enable
      condition.
- [x] T003 [US1] Replace Flox with devenv in `README.md`, update the tooling claim in
      `.specify/memory/current-system.md`, and exclude Serena-owned config from treefmt in
      `treefmt.nix`.

## Final Phase: Cross-Target Verification and Memory

- [X] T004 Format the changed Nix source and evaluate both host package lists.
- [X] T005 Confirm no Flox references remain in active configuration and that trust/cache
  settings remain otherwise unchanged.
- [X] T006 Reconcile `.specify/memory/current-system.md` from verified implementation
  evidence and run `.specify/scripts/bash/validate-project.sh`.

## Dependencies and Execution

- T001 precedes implementation; T004 and T005 depend on T002 and T003.
- T006 follows successful verification.
