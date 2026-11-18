# Tasks: Lock Global Skill Sources

**Input**: Design documents from `/specs/024-locked-global-skill-sources/`

## Phase 1: Lock skill inputs

- [x] T001 Declare dotnet/skills, GoogleChrome/modern-web-guidance, and nuxt/ui as non-flake inputs in `flake.nix`.
- [x] T002 Replace direct fetch declarations with the corresponding locked inputs in `modules/home/default.nix`.
- [x] T003 Generate lockfile entries for all skill sources in `flake.lock`.
- [x] T004 Update `.specify/memory/current-system.md` with the lock-based update lifecycle.
- [x] T005 Format and evaluate both supported host configurations and run Spec Kit governance validation.

## Dependencies & Execution Order

- T001 and T002 precede T003; T004 and T005 follow the source changes.

## Notes

- `nix-skills` is already a locked input and needs no source change.
- The CI updater and its schedule require no workflow modification.
