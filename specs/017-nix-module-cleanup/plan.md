# Implementation Plan: Nix Module Cleanup

**Feature Directory**: `017-nix-module-cleanup` | **Date**: 2026-09-30 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `specs/017-nix-module-cleanup/spec.md`

Read the specification, `.specify/memory/constitution.md`, and
`.specify/memory/current-system.md` before filling this plan.

## Summary

Keep Nixpkgs' module library argument intact and pass the repo library and Home Manager
activation helpers through explicit custom arguments. Extract the Niri KDL into its own
source file, separate developer tool packages from common utilities, and bind shared test
derivations once in `perSystem`.

## Technical Context

**Configuration language**: Nix

**Flake architecture**: `flake-parts`, NixOS, Home Manager

**Affected hosts**: `nixos`, `nixos-wsl`

**Affected layers**: flake, internal library consumers, shared NixOS, Home Manager,
module-discovery tests, configuration tests, current-system memory

**Inputs/packages/options**: Pinned Nixpkgs, Home Manager, `inputs.self`, the repo-owned
`lib.internal` values, Home Manager activation DAG helper, `programs.niri` configuration

**State or migration impact**: None; preserve system and Home Manager state versions.

**Security impact**: None; preserve the existing privilege, credential, cache, and
unfree-package policies.

**Rollback**: Revert the focused commits; no runtime state migration is involved.

**Constraints**: Preserve both hosts' evaluated package sets and generated configurations.
`internal.scanPaths` only discovers Nix modules and its exact-list unit assertion must be
updated for the new developer-tools module.

## Constitution Check

_GATE: Must pass before design and be re-checked after the design is complete._

| Principle                           | Evidence of compliance                                                                                                       | Status |
| ----------------------------------- | ---------------------------------------------------------------------------------------------------------------------------- | ------ |
| Declarative, reproducible ownership | All settings remain in the flake, Nix modules, and checked-in native configuration files.                                    | PASS   |
| Shared modules and host boundaries  | Host-owned Niri output remains in `systems/`; shared Niri settings and module discovery remain shared.                       | PASS   |
| State compatibility                 | No state versions or persistent runtime formats change.                                                                      | PASS   |
| Explicit security boundaries        | No privilege, credential, trust, socket, or unfree policy changes.                                                           | PASS   |
| Verification follows impact         | Format, discovery, generated-configuration assertions, and both host builds cover changed and preserved behavior.            | PASS   |
| Current-system memory               | The architecture's module argument description and current module grouping will be synchronized after evidence is available. | PASS   |
| Smallest coherent design            | Use named module arguments and source files; do not add generic module factories or split the small feature modules.         | PASS   |

## Current and Target Design

### Current

`flake.nix` extends Nixpkgs `lib` with repo and Home Manager attributes, then passes that
extended value as `specialArgs.lib` to both NixOS and Home Manager. Shared Home Manager
modules receive the same custom library. Niri's KDL lives inside `modules/home/niri.nix` as
a long Nix string. `modules/home/utils.nix` mixes basic command-line programs and packages
for development. The flake imports unit and configuration test derivations separately for
the `packages` and `checks` output paths.

### Target

Keep the built-in module `lib` untouched. Pass the repo library and Home Manager activation
helpers as named `internal` and `hm` custom arguments, and update only their consumers.
Store shared Niri settings in `modules/home/niri.kdl` with a valid KDL comment marker; the
Nix module substitutes the host's output fragment there. Move development language tools
and development-specific programs to
`modules/home/devtools.nix`, keep common shell tools in `utils.nix`, and preserve all
existing defaults and GUI conditions. Bind test derivations once and expose the same values
as both packages and checks.

### Decision Rationale

The Nixpkgs module-system reference reserves `lib` for the Nixpkgs library and recommends
distinct custom argument names. A named `internal` argument is also needed during import
resolution because module discovery calls `internal.scanPaths`. A native KDL file is easier
to edit and inspect with KDL tooling than a large Nix multiline string. The package split
uses one additional discovered module because developer dependencies are a distinct group;
it does not introduce a helper abstraction. Shared derivation bindings prevent repeated
declarations without changing output paths.

Alternatives considered: keeping custom values under `lib` was rejected because it replaces
a reserved module argument; splitting each package into its own file was rejected as
unnecessary fragmentation; extracting every `perSystem` block was rejected because the
flake remains a compact single-system configuration.

## Repository Touchpoints

```text
flake.nix
modules/nixos/default.nix
modules/nixos/system/default.nix
modules/home/default.nix
modules/home/bash.nix
modules/home/ghostty.nix
modules/home/codex.nix
modules/home/niri.nix
modules/home/niri.kdl
modules/home/utils.nix
modules/home/devtools.nix
systems/x86_64-linux/nixos/default.nix
systems/x86_64-linux/nixos-wsl/default.nix
systems/x86_64-linux/nixos-wsl/wsl.nix
lib/internal/default.nix
tests/unit.nix
tests/configuration.nix
tests/vm-nixos.nix
tests/vm-wsl-mock.nix
.specify/memory/current-system.md
specs/017-nix-module-cleanup/
```

## Verification Matrix _(mandatory)_

| Requirement/story     | Target                         | Verification command or observation                                         | Local/CI |
| --------------------- | ------------------------------ | --------------------------------------------------------------------------- | -------- |
| FR-001, FR-002 / US1  | NixOS and Home Manager modules | `nix build .#configuration-tests --no-link`                                 | Local    |
| FR-003 / US2          | Home Manager Niri output       | Generated config assertion plus `nix build .#configuration-tests --no-link` | Local    |
| FR-004, FR-006 / US2  | Home Manager module discovery  | `nix build .#unit-tests --no-link`                                          | Local    |
| FR-005 / US2          | Flake outputs                  | `nix flake check` and evaluate existing package/check output paths          | Local    |
| INV-001               | Both supported hosts           | `nix build .#nixos-build .#nixos-wsl-build --no-link`                       | Local    |
| Formatting            | Repository                     | `nix fmt -- --ci`                                                           | Local    |
| Repository governance | Spec Kit artifacts             | `.specify/scripts/bash/validate-project.sh`                                 | Local    |
| Runtime behavior      | NixOS and WSL integration      | `nix build .#vm-test-nixos .#vm-test-wsl-mock --no-link`                    | CI       |

## Delivery and Recovery

1. Change custom module arguments and update the direct consumers plus assertions.
2. Extract KDL and split the developer-tools group, updating the exact discovery test.
3. Deduplicate the flake test derivation bindings and update current-system architecture
   prose.
4. Run the local verification matrix, then use both VM tests in CI as the runtime check.
5. Revert commits to roll back; no activation or state migration is required for these
   source-level refactors.

## Current-System Reconciliation

After implementation, update the architecture text to state that Nixpkgs `lib` remains the
module library and repo values are passed separately. Update the Home Manager feature list
only if its utility/developer-tools grouping description changes. No capability, host
support, security, state, workflow, or known-limitation claims should otherwise change.

The mandatory `speckit.system-memory.sync` hook performs this reconciliation after
implementation and records its evidence in `tasks.md`.

## Complexity Tracking

| Complexity                                                   | Why required                                                       | Simpler alternative rejected because                                            |
| ------------------------------------------------------------ | ------------------------------------------------------------------ | ------------------------------------------------------------------------------- |
| One extra Home Manager module (`devtools.nix`) and test path | Separates a coherent package group while retaining auto-discovery. | Keeping developer stacks in `utils.nix` obscures ownership; one file is enough. |
