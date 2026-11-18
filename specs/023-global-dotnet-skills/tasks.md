# Tasks: Global Official .NET Skills

**Input**: Design documents from `/specs/023-global-dotnet-skills/`

## Phase 1: Implementation

- [x] T001 Pin `dotnet/skills` at an immutable revision with a fixed source hash in `modules/home/default.nix`.
- [x] T002 Derive uniquely named Codex skill links for every plugin skill containing `SKILL.md` in `modules/home/default.nix`.
- [x] T003 Update `.specify/memory/current-system.md` to describe the implemented .NET skill catalog.
- [x] T004 Format and evaluate both supported host configurations, including generated Codex skills.

## Dependencies & Execution Order

- T001 and T002 establish the feature; T003 and T004 follow the implementation.

## Notes

- The dynamic source scan intentionally includes only plugin skill directories containing `SKILL.md`.
- Codex skill link names include the plugin name so duplicate leaf names cannot overwrite each other.
