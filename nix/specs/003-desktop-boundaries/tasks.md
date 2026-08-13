# Tasks: Desktop Boundaries

**Input**: `spec.md` and `plan.md` from `specs/003-desktop-boundaries/`

## Phase 1: Guardrails and Baseline

- [x] T001 Record current resume command, display stanza, and WSL cursor/package behavior from `modules/home/niri.nix`, `modules/home/default.nix`, and `tests/configuration.nix`
- [x] T002 Add failing generated assertions for native resume, host-owned display, and GUI-disabled cursor absence in `tests/configuration.nix`

## Phase 2: User Story 1 - Resume a Niri Session Correctly

- [x] T003 [US1] Replace `hyprctl dispatch dpms on` with `niri msg action power-on-monitors` in `modules/home/niri.nix`
- [x] T004 [US1] Add practical Niri command availability validation in `tests/vm-nixos.nix`

## Phase 3: User Story 2 - Keep Host Display Details Host-Owned

- [x] T005 [US2] Add a host-supplied output fragment option and remove `eDP-1` from shared text in `modules/home/niri.nix`
- [x] T006 [US2] Supply the existing `eDP-1` mode and scale from `systems/x86_64-linux/nixos/default.nix`

## Phase 4: User Story 3 - Keep WSL GUI-Free

- [x] T007 [US3] Gate the full `home.pointerCursor` declaration on `internal.gui.enable` in `modules/home/default.nix`
- [x] T008 [US3] Verify pointer cursor and Bibata absence with `nix build .#configuration-tests --no-link`

## Final Phase: Cross-Target Verification and Memory

- [x] T009 Run `nix fmt`, `nix build .#unit-tests .#configuration-tests --no-link`, and `nix flake check --no-build`
- [x] T010 Run `nix build .#nixos-build .#nixos-wsl-build --no-link`
- [x] T011 Run/evaluate `.#vm-test-nixos` and record any CI execution deferral
- [x] T012 Reconcile affected desktop and host-boundary claims in `.specify/memory/current-system.md`
- [x] T013 Run `.specify/scripts/bash/validate-project.sh`

## Dependencies and Execution

- T001-T002 precede T003-T008; T005 precedes T006. T009-T013 follow all stories.

## Completion Rules

- All requirements and invariants map to tasks with exact paths or commands.
