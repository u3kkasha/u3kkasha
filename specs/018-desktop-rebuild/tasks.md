---
description: "Nix configuration implementation tasks"
---

# Tasks: Bare-Metal Desktop Rebuild

**Input**: `spec.md` and `plan.md` from `specs/018-desktop-rebuild/`

**Organization**: Tasks are grouped by independently verifiable configuration outcome.

## Phase 1: Guardrails and Baseline

**Purpose**: Establish current behavior and checks that must remain green.

- [ ] T001 Record current `nixos`, `nixos-wsl`, unit, and configuration evaluation results using the verification matrix in `specs/018-desktop-rebuild/plan.md`
- [ ] T002 Inspect current module discovery and package ownership in `modules/home/default.nix`, `modules/nixos/desktop/default.nix`, `flake.nix`, and `tests/configuration.nix`
- [ ] T003 Add targeted assertions for Niri-flake, Noctalia project-package ownership, cache hints, WSL GUI absence, and removed user applications in `tests/configuration.nix`

**Checkpoint**: Baseline is understood and new assertions fail for the intended reason.

## Phase 2: User Story 1 - Cohesive Bare-Metal Desktop (Priority: P1)

**Goal**: Rebuild the `nixos` desktop around validated Niri-flake and cached Noctalia project packages without affecting WSL.

**Independent Test**: `nix build .#nixos-build --no-link` succeeds and generated Niri/Noctalia configuration is validated.

- [ ] T004 [P] [US1] Add pinned `niri-flake` and project-cache `nixConfig` entries to `flake.nix`, preserving existing cache policy and dependency follows
- [ ] T005 [P] [US1] Add the Niri-flake public cache key and module import path to `flake.nix` and `modules/nixos/default.nix`
- [ ] T006 [US1] Replace nixpkgs Niri ownership with Niri-flake NixOS/Home Manager modules in `modules/nixos/desktop/default.nix`, `modules/home/niri.nix`, and `flake.nix`
- [ ] T007 [US1] Port existing Niri behavior, keybindings, idle integration, and host-owned `eDP-1` output into validated Niri-flake settings in `modules/home/niri.nix`, `modules/home/niri.kdl`, and `systems/x86_64-linux/nixos/default.nix`
- [ ] T008 [US1] Make Noctalia project package/module ownership explicit in `modules/home/noctalia/config.nix` and remove duplicate system installation from `modules/nixos/desktop/default.nix`
- [ ] T009 [US1] Refine Noctalia palette, wallpaper, panel, launcher, and desktop settings in `modules/home/noctalia/config.nix` while retaining Catppuccin only for selected non-shell applications
- [ ] T010 [US1] Remove duplicate or conflicting polkit, portal, keyring, and session setup introduced by Niri-flake while preserving required desktop behavior in `modules/nixos/desktop/default.nix`
- [ ] T011 [US1] Verify the bare-metal desktop composition with `nix build .#nixos-build --no-link` and targeted generated-configuration assertions

**Checkpoint**: User Story 1 is independently satisfied.

## Phase 3: User Story 2 - Lean User Profile Without Losing Infrastructure (Priority: P2)

**Goal**: Preserve existing CLI/agent applications while retaining Docker, gaming, development, MCP, and WSL capabilities.

**Independent Test**: Configuration tests prove existing applications and retained infrastructure remain enabled.

- [ ] T012 [US2] Preserve Yazi, Codex, OpenCode, and shared agent configuration ownership in `modules/home/default.nix`, `modules/home/yazi.nix`, `modules/home/codex.nix`, and `modules/home/opencode.nix`
- [ ] T013 [US2] Update configuration assertions in `tests/configuration.nix` to prove existing CLI/agent applications remain enabled alongside MCP, Docker, gaming, development, and WSL capabilities
- [ ] T014 [US2] Verify retained user tooling and infrastructure with `nix build .#configuration-tests .#nixos-wsl-build --no-link`

**Checkpoint**: User Story 2 is independently satisfied.

## Final Phase: Cross-Target Verification and Memory

- [ ] T017 Run formatting, actionlint, unit tests, configuration tests, and affected flake checks
- [ ] T018 Run both host builds and bare-metal/WSL VM tests required by `plan.md`
- [ ] T019 Confirm cache trust, security, state-version, rollback, WSL, and retained-infrastructure invariants from `spec.md`
- [ ] T020 Reconcile `.specify/memory/current-system.md` through the mandatory `speckit.system-memory.sync` hook
- [ ] T021 Run `.specify/scripts/bash/validate-project.sh`
- [ ] T022 Run `$speckit-converge` and resolve remaining implementation gaps

## Dependencies and Execution

- Baseline and guardrail tasks precede implementation.
- Tasks touching the same Nix module or expected-list assertion run sequentially.
- Shared-module changes are incomplete until both host evaluations/builds pass.
- Current-system reconciliation occurs after implementation evidence exists and before convergence.

## Completion Rules

- All requirements, invariants, and acceptance scenarios map to at least one task.
- Every completed task is marked `[X]`.
- No placeholder or sample task remains.
- `$speckit-analyze` reports no unresolved critical inconsistency before implementation.
- `$speckit-converge` reports no remaining implementation gap before review.
