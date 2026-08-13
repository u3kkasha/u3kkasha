# Nix Best-Practices and Clean-Code Review

Date: 2026-08-13

Status: Open; findings are recorded for later remediation.

Scope: Flake architecture, NixOS and Home Manager modules, host composition, security boundaries, reproducibility, and verification.

## Summary

The repository is a strong personal NixOS configuration. It has deterministic pinned inputs, clear host/shared-module separation, feature modules built with `mkEnableOption` and `mkIf`, formatting and lint checks, secret scanning, module-level assertions, and NixOS VM tests.

The main opportunities are to make the stated security boundaries match runtime privileges, keep quick tests genuinely small, fix one Niri runtime command, and separate host-specific configuration from reusable modules.

## Open Findings

### 1. Podman's Docker socket grants root-equivalent access

Priority: High

Location: `modules/nixos/podman/default.nix`, `modules/nixos/system/default.nix`

`virtualisation.podman.dockerSocket.enable` exposes a Docker-compatible system socket, while the configured user is automatically added to the `podman` group. NixOS documents that members of this group can gain root access.

Recommended resolution:

- Keep `dockerCompat` but disable the system Docker socket when API compatibility is unnecessary; or
- Retain it and document the `podman` group as an intentional root-equivalent privilege boundary.

### 2. The unit-test derivation has an integration-sized closure

Priority: High

Location: `tests/unit.nix`

The unit test evaluates full host and Home Manager configurations and reads generated MCP and Codex configuration. On a cold store this realizes large agent, browser, and theming dependencies, including Chromium and Serena.

Recommended resolution:

- Keep pure module assertions in a small, fast test derivation.
- Move generated configuration and package-closure checks into a separate integration check.
- Update documentation so that the expected cost of each check is clear.

### 3. Hyprland's `hyprctl` is called from the Niri session

Priority: High

Location: `modules/home/niri.nix`

The Hypridle `after_sleep_cmd` runs `hyprctl dispatch dpms on`, but this configuration runs Niri and does not install `hyprctl`. The same file already uses Niri's native monitor action elsewhere.

Recommended resolution: replace the command with `niri msg action power-on-monitors` and add a configuration validation check using `niri validate` where practical.

### 4. Git identity values are declared but not applied

Priority: Medium

Location: `lib/internal/default.nix`, `modules/home/git.nix`

The shared `name` and `email` values are not used by the Git configuration. A clean installation therefore does not receive a declarative author identity.

Recommended resolution: set `programs.git.settings.user.name` and `programs.git.settings.user.email` from `lib.internal`, or remove the unused values and their test.

### 5. Disabling GUI configuration leaves GUI assets installed

Priority: Medium

Location: `modules/home/default.nix`, `tests/unit.nix`

`internal.gui.enable = false` disables the main GUI programs but leaves the pointer cursor and its package enabled. The WSL Home Manager closure consequently still includes `bibata-cursors`.

Recommended resolution: guard pointer cursor and other desktop-only configuration with `lib.mkIf config.internal.gui.enable`, then expand the WSL closure test.

### 6. The nixd configuration discards string dependency context

Priority: Medium

Location: `modules/home/nixd.nix`

`builtins.unsafeDiscardStringContext` places the linked input path in nixd's generated configuration without preserving that dependency edge in the configuration derivation. A separate data-file declaration currently keeps the link farm available, but this relationship is implicit.

Recommended resolution: preserve string context if evaluation allows it. If discarding context is necessary to avoid a cycle, document the reason and test that the locked-input link remains in the activated closure.

### 7. Repeated Home Manager activation destroys the previous backup

Priority: Medium

Location: `modules/nixos/system/default.nix`

The custom backup command recursively removes an existing `.backup` before replacing it. Repeated activation can therefore destroy the only earlier recoverable copy.

Recommended resolution: use timestamped backups, fail when a backup already exists, or use Home Manager's standard backup-extension behavior.

## Maintainability Improvements

- Split the large embedded Niri KDL configuration by concern, or at least move the `eDP-1` output mode into the physical host module.
- Deduplicate cache URLs and public keys currently declared in both `flake.nix` and the system module.
- Replace broad `nixpkgs.config.allowUnfree = true` with `allowUnfreePredicate` when the required package set is stable.
- Replace the hard-coded username in VM scripts with the shared internal username.

## Existing Strengths

- Deterministic `scanPaths` behavior with discovery-contract tests.
- Host-scoped NixOS-WSL integration.
- Locked inputs and consistent `follows` relationships.
- Packaged MCP servers instead of runtime dependency resolvers.
- Stable `stateVersion` policy.
- Root-only Nix daemon trust.
- Formatting, Statix, Deadnix, Gitleaks, unit checks, and VM integration tests in CI.

## Verification Baseline

At review time:

- `nix build .#checks.x86_64-linux.formatting --no-link` passed.
- `nix build .#unit-tests --no-link` passed.
- `nix flake check --no-build` passed after cold-store dependencies were realized.
- VM test derivations evaluated, but their test VMs were not built during the review.
