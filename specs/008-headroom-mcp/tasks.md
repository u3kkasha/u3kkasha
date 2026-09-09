---
description: "Nix configuration implementation tasks"
---

# Tasks: Full Headroom Integration

**Input**: `spec.md` and `plan.md` from `specs/008-headroom-mcp/`

## Phase 1: Guardrails and Source

- [x] T001 Record `git status --short` and pass `nix build .#unit-tests --no-link` as the baseline
- [x] T002 Add and lock `headroom-src` v0.36.0 in `flake.nix` and `flake.lock`
- [x] T003 Add failing complete-package, offline-asset, MCP, and proxy-launcher assertions to `tests/configuration.nix`

## Phase 2: Foundational Full Package

- [x] T004 Define fixed-revision model, OCR, and tokenizer assets in `packages/headroom-models.nix`
- [x] T005 Define private compatible Python dependency pins and Headroom's complete `[all]` derivation in `packages/headroom.nix`
- [x] T006 Expose `packages.headroom` in `flake.nix` and pass `nix build .#headroom --no-link`

## Phase 3: User Story 1 - Use Complete Headroom Tooling (Priority: P1)

**Independent Test**: Representative checks for every official `[all]` group pass offline.

- [x] T007 [US1] Add representative offline import/initialization checks for every complete-bundle group to `tests/headroom.nix`
- [x] T008 [US1] Verify all model/helper paths are immutable and runtime downloads are disabled with `nix build .#headroom-tests --no-link`

## Phase 4: User Story 2 - Use Headroom From Every MCP Agent (Priority: P1)

**Independent Test**: Both hosts project the same server to three clients and both VMs pass MCP discovery/compress/retrieve.

- [x] T009 [P] [US2] Extend both-host Codex, Antigravity CLI, and OpenCode projection assertions in `tests/configuration.nix`
- [x] T010 [P] [US2] Add MCP JSON-RPC discovery and compression/retrieval runtime coverage to `tests/vm-nixos.nix`
- [x] T011 [P] [US2] Add MCP JSON-RPC discovery and compression/retrieval runtime coverage to `tests/vm-wsl-mock.nix`
- [x] T012 [US2] Register the store-owned `headroom mcp serve` entry in `modules/home/mcp.nix`
- [x] T013 [US2] Verify exact registry, arguments, store ownership, and no-resolver behavior with `nix build .#configuration-tests --no-link`

## Phase 5: User Story 3 - Opt Into Transparent Codex Compression (Priority: P2)

**Independent Test**: A fake Codex session observes healthy loopback routing and cleanup without any configuration-file mutation.

- [x] T014 [P] [US3] Add `headroom.nix` to the exact discovered Home Manager module list in `tests/unit.nix`
- [x] T015 [P] [US3] Add loopback, normal-Codex, global-environment, and config-integrity assertions to `tests/configuration.nix`
- [x] T016 [US3] Create `internal.headroom` package installation and the `codex-headroom` ephemeral launcher in `modules/home/headroom.nix`
- [x] T017 [US3] Enable `internal.headroom` by default in `modules/home/default.nix` and pass `nix build .#unit-tests .#configuration-tests --no-link`
- [x] T018 [US3] Verify the launcher lifecycle and byte-identical Codex configuration on the live host; keep QEMU VM coverage focused on MCP integration

## Final Phase: Cross-Target Verification and Memory

- [x] T019 Run `nix fmt` and the formatting/actionlint checks from `plan.md`
- [x] T020 Run `nix build .#nixos-build .#nixos-wsl-build --no-link` and both VM targets
- [x] T021 Audit `git diff` for credentials, global provider variables, external telemetry, non-loopback listeners, unfree policy, trust, and state-version changes
- [x] T022 Execute the mandatory `speckit.system-memory.sync` hook and reconcile `.specify/memory/current-system.md`
- [x] T023 Run `.specify/scripts/bash/validate-project.sh`, then `$speckit-converge`, and complete any appended work

## Dependencies and Execution

- T003 precedes implementation; T004-T005 precede T006; T006 precedes all user stories.
- US1 proves the complete package before US2/US3 consume it.
- T009-T011 are parallel after T008; T012 makes their configuration/runtime expectations pass.
- T014-T015 are parallel; T016-T18 complete the opt-in proxy outcome.
- T019-T023 follow all implementation tasks.

## Completion Rules

- Every completed task is marked `[X]`; no placeholder remains.
- Analysis must report no unresolved critical inconsistency before implementation resumes.
- Both host builds and both VM tests are mandatory for this shared runtime/security change.
- Memory synchronization and convergence occur after implementation evidence exists.
