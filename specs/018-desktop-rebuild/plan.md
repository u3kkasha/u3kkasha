# Implementation Plan: Bare-Metal Desktop Rebuild

**Feature Directory**: `018-desktop-rebuild` | **Date**: 2026-10-10 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `specs/[###-feature-name]/spec.md`

Read the specification, `.specify/memory/constitution.md`, and
`.specify/memory/current-system.md` before filling this plan.

## Summary

Rebuild only the bare-metal graphical composition around `sodiboo/niri-flake` and the
Noctalia project flake, while retaining Docker, gaming, development, CLI, MCP/agent, and WSL
capabilities.

## Technical Context

**Configuration language**: Nix

**Flake architecture**: `flake-parts`, NixOS, Home Manager

**Affected hosts**: `nixos` desktop behavior; `nixos-wsl` verification and shared-module
closure only, with no graphical desktop.

**Affected layers**: flake inputs/cache, shared NixOS desktop module, shared Home Manager
desktop defaults, bare-metal host, configuration tests, system memory.

**Inputs/packages/options**: `niri`, `niri.nixosModules.niri`, `niri.homeModules.config`,
`programs.niri.settings`, `programs.niri.package`, `noctalia`,
`inputs.noctalia.homeModules.default`, `programs.noctalia.package`,
`programs.noctalia.checkConfig`, `niri-flake.cache.enable`, Noctalia and Niri Cachix
substituters and public keys.

**State or migration impact**: No state-version change; generated runtime Noctalia state is
preserved and previous generations provide rollback.

**Security impact**: No new privilege or credential boundary; two additional public binary
caches require explicit trust keys and are documented in the flake.

**Rollback**: Revert the focused commit or boot/switch to the previous NixOS generation.

**Constraints**: `nixos-wsl` must remain GUI-disabled; Niri and Noctalia project package
versions must be compatible with the pinned nixpkgs; module discovery expected lists must
remain exact; desktop-only settings must remain host-scoped.

## Constitution Check

_GATE: Must pass before design and be re-checked after the design is complete._

| Principle                           | Evidence of compliance                                                                              | Status |
| ----------------------------------- | --------------------------------------------------------------------------------------------------- | ------ |
| Declarative, reproducible ownership | Flake inputs, NixOS modules, and Home Manager own all persistent desktop configuration.             | PASS   |
| Shared modules and host boundaries  | Bare-metal output stays under `systems/x86_64-linux/nixos`; WSL remains GUI-disabled.               | PASS   |
| State compatibility                 | State versions remain unchanged; runtime state is not migrated.                                     | PASS   |
| Explicit security boundaries        | Cache trust keys are explicit; no new privileges or credentials.                                    | PASS   |
| Verification follows impact         | Formatting, unit/configuration checks, both host builds, and relevant VM checks are mapped below.   | PASS   |
| Current-system memory               | Desktop architecture, caches, tooling, and verification claims are reconciled after implementation. | PASS   |
| Smallest coherent design            | Reuses Niri/Noctalia and removes duplicate ownership; excludes DMS and Stylix.                      | PASS   |

## Current and Target Design

### Current

The NixOS desktop module enables the nixpkgs Niri module and installs a Noctalia package in
`environment.systemPackages`. Home Manager writes a raw Niri KDL file and separately
configures Noctalia. Shared Home Manager defaults enable user CLI/agent modules on both
host compositions, with GUI gating for some but not all user tools.

### Target

The flake pins `sodiboo/niri-flake` and `noctalia-dev/noctalia`, exposes their public cache
hints, and imports the Niri module needed for the bare-metal composition. Home Manager uses
the Noctalia project package/module and the Niri structured configuration module. The
bare-metal host owns its output and graphical imports; WSL keeps its existing headless
imports. Existing CLI/agent, Docker, gaming, development, MCP, and WSL modules remain.

### Decision Rationale

The project Niri and Noctalia packages are selected to use their upstream binary caches and
to keep compositor/shell versions coherent with their validation modules. Nixpkgs-only
packages would reduce inputs but lose the intended project cache path. DankMaterialShell is
excluded for weight and integration complexity; Stylix is excluded because Noctalia is the
single desktop theme authority. Raw KDL remains only where structured Niri settings cannot
express a needed feature.

## Repository Touchpoints

```text
flake.nix
flake.lock
lib/internal/default.nix
modules/nixos/desktop/default.nix
modules/home/default.nix
modules/home/niri.nix
modules/home/niri.kdl
modules/home/noctalia/config.nix
systems/x86_64-linux/nixos/default.nix
systems/x86_64-linux/nixos-wsl/default.nix
tests/unit.nix
tests/configuration.nix
modules/home/{yazi,codex,opencode}.nix (remove if no retained consumer)
specs/018-desktop-rebuild/
```

## Verification Matrix _(mandatory)_

| Requirement/story  | Target                  | Verification command or observation                 | Local/CI |
| ------------------ | ----------------------- | --------------------------------------------------- | -------- |
| FR-001 / US1       | `nixos` desktop         | `nix build .#nixos-build --no-link`                 | Local/CI |
| FR-002 / US1       | flake caches            | `nix flake check` and inspect evaluated `nixConfig` | Local/CI |
| FR-005 / US2       | both Home Manager hosts | `nix build .#configuration-tests --no-link`         | Local/CI |
| FR-006 / invariant | `nixos-wsl`             | `nix build .#nixos-wsl-build --no-link`             | Local/CI |
| shared behavior    | repository              | `nix build .#unit-tests --no-link`                  | Local/CI |

## Delivery and Recovery

1. Add and lock the project inputs/cache hints, then update module imports and ownership.
2. Replace the desktop configuration while preserving all existing user CLI/agent modules.
3. Run formatting, evaluation, targeted assertions, host builds, and VM checks before any
   activation; activation remains the operator's decision.
4. Revert the focused commit or select the previous NixOS generation if runtime behavior is
   unacceptable.

## Current-System Reconciliation

After implementation, update only the claims proven to have changed:

- Record Niri-flake and Noctalia as the bare-metal desktop package/module path, cache policy,
  retained infrastructure, existing user tools, and updated verification commands.

The mandatory `speckit.system-memory.sync` hook performs this reconciliation and records
the result in the feature tasks.

## Complexity Tracking

> Fill only for justified constitution violations or deliberately retained complexity.

| Complexity                          | Why required                                                | Simpler alternative rejected because                                                      |
| ----------------------------------- | ----------------------------------------------------------- | ----------------------------------------------------------------------------------------- |
| Two project flake inputs and caches | Required for upstream packages and reproducible validation. | Nixpkgs-only desktop packages would be leaner but lose the requested project cache paths. |
