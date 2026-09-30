---
description: "Nix configuration implementation tasks"
---

# Tasks: Home Manager Agent Context

**Input**: `spec.md` and `plan.md` from `specs/015-agent-context-home-manager/`

**Organization**: Tasks are grouped by the requested sequence and independently verifiable configuration outcomes.

## Phase 1: Guardrails and Baseline

**Purpose**: Confirm the current generated configuration assertions and prepare updated assertions.

- [x] T001 Inspect `tests/configuration.nix` assertions covering Antigravity, Gemini, global agent files, and MCP outputs.
- [x] T002 Add configuration assertions for absent Antigravity and Gemini outputs in `tests/configuration.nix`.

**Checkpoint**: Removal assertions express the requested post-removal state.

## Phase 2: User Story 1 - Remove Antigravity CLI (Priority: P1)

**Goal**: Remove the unused Antigravity CLI and its Gemini configuration before migrating global context.

**Independent Test**: Both supported host evaluations contain no Antigravity program/package or Gemini global file/configuration output.

- [x] T003 [US1] Remove the Antigravity CLI program and package binding from `modules/home/utils.nix`.
- [x] T004 [US1] Remove the Gemini instruction mapping from `modules/home/agent-instructions.nix` while retaining the Codex mapping until migration.
- [x] T005 [US1] Remove obsolete Antigravity and Gemini assertions from `tests/configuration.nix`.

**Checkpoint**: The unused client and all Gemini-specific generated outputs are absent.

## Phase 3: User Story 2 - Use native Home Manager context (Priority: P2)

**Goal**: Manage Codex and OpenCode global context using their native Home Manager options and the shared source.

**Independent Test**: Both hosts evaluate to identical Codex and OpenCode global context content from `modules/home/agent-instructions.md`.

- [x] T006 [US2] Configure `programs.codex.context` from the shared Markdown source in `modules/home/codex.nix`.
- [x] T007 [US2] Configure `programs.opencode.context` from the same shared Markdown source in `modules/home/opencode.nix`, preserving repository instruction paths.
- [x] T008 [US2] Replace linked-file context assertions with generated shared-source, project-instruction, and MCP integration assertions in `tests/configuration.nix`.
- [x] T009 [US2] Delete `modules/home/agent-instructions.nix` and remove its filename from the exact discovered-module list in `tests/unit.nix`.

**Checkpoint**: Both configured clients consume one shared instruction source through native Home Manager options.

## Final Phase: Cross-Target Verification and Memory

- [x] T010 Run formatting, unit assertions, and generated configuration assertions for both supported hosts with `nix build .#checks.x86_64-linux.formatting .#unit-tests .#configuration-tests --no-link`.
- [x] T011 Reconcile `.specify/memory/current-system.md` through the mandatory `speckit.system-memory.sync` hook using the verified implementation evidence.
- [x] T012 Run `.specify/scripts/bash/validate-project.sh`.
- [x] T013 Build both supported host systems with `nix build .#nixos-build .#nixos-wsl-build --no-link`.

## Dependencies and Execution

- T001-T002 precede the removal work.
- Complete T003-T005 before T006-T008 to preserve the explicitly requested removal-then-migration sequence.
- T010 and T013 depend on all implementation work; T011 and T012 follow successful verification.
- Tasks changing the same file are sequential; no safe parallel work is identified.

## Completion Rules

- All requirements, invariants, and acceptance scenarios map to at least one task.
- Every completed task is marked `[X]`.
- No placeholder or sample task remains.
- `$speckit-analyze` reports no unresolved critical inconsistency before implementation.
- `$speckit-converge` reports no remaining implementation gap before review.
