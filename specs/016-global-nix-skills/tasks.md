# Tasks: Global Nix Skills

**Input**: Design documents from `/specs/016-global-nix-skills/`

## Phase 1: Shared Configuration

- [x] T001 Add and lock the nix-skills flake input in `flake.nix` and `flake.lock`.
- [x] T002 Import the nix-skills Home Manager module and configure the six selected skills for Codex and OpenCode in `modules/home/default.nix`.
- [x] T003 Update global agent tooling documentation in `.specify/memory/current-system.md`.
- [x] T004 Format changed Nix files and confirm the lockfile pins nix-skills.

## Verification Results

- `nix fmt` formatted the changed Nix files.
- Nix syntax parsing passed for `flake.nix` and `modules/home/default.nix`.
- Nix evaluation confirmed the exact skill and agent lists plus generated skill links for both hosts.
- `jq` validated `flake.lock`; `git diff --check` and Spec Kit governance validation passed.
- Full build and test suites were not run.

## Dependencies

- T001 precedes T002.
- T002 precedes T003 and T004.
- T004 follows all implementation tasks.
