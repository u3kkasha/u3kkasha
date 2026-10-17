# Tasks: Single Cache Source

**Input**: Design documents from `specs/019-single-cache-source/`

## Implementation

- [x] T001 Add the Niri URL and key to `lib/internal/cache.nix`.
- [x] T002 Disable duplicate Niri cache settings in `modules/nixos/system/default.nix`.
- [x] T003 Remove duplicated `nixConfig` cache values from `flake.nix`.
- [x] T004 Assert both hosts exactly match the canonical cache lists in `tests/configuration.nix`.
- [x] T005 Update `.specify/memory/current-system.md` with canonical cache ownership and bootstrap behavior.
- [x] T006 Add `nixpkgs.follows` for `catppuccin` and `nixos-hardware` and refresh `flake.lock`.

## Verification

- [x] T007 Run `nix fmt`.
- [x] T008 Run `nix build .#configuration-tests --no-link`.
