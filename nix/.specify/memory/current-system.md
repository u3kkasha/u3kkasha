# Current System

This document describes implemented reality for the Nix configuration. Source code and
executable checks remain the evidence; this file is the canonical prose projection of
that evidence. Update it only when implemented behavior changes.

## Capability Status

| Capability                    | Status            | Supported path                                                | Verification                                   |
| ----------------------------- | ----------------- | ------------------------------------------------------------- | ---------------------------------------------- |
| Bare-metal NixOS host         | Operational       | `nixosConfigurations.nixos`                                   | `nix build .#nixos-build`                      |
| WSL NixOS host                | Operational       | `nixosConfigurations.nixos-wsl`                               | `nix build .#nixos-wsl-build`                  |
| Shared Home Manager layer     | Operational       | Home Manager as a NixOS module for the configured user        | `nix build .#unit-tests`                       |
| Automatic module discovery    | Operational       | `lib.internal.scanPaths` for NixOS and Home Manager trees     | Exact discovered-path unit tests               |
| Podman container runtime      | Operational       | Podman with Docker-compatible CLI and system socket           | Unit assertions and both VM/build targets      |
| Central MCP registry          | Operational       | `programs.mcp.servers` shared by MCP-aware clients            | Generated-configuration unit assertions        |
| Local developer workflow      | Operational       | Flake dev shell, `nh`, treefmt, Gitleaks, and pre-push checks | `nix flake check`                              |
| VM integration verification   | Operational in CI | Bare-metal and WSL-mock test derivations                      | `nix build .#vm-test-nixos .#vm-test-wsl-mock` |
| Spec-driven change governance | Operational       | Spec Kit Codex skills, Nix templates, and system-memory hook  | `.specify/scripts/bash/validate-project.sh`    |

Status vocabulary: **Operational** is supported and verifiable; **Partial** works with a
documented limitation; **Planned** is accepted but not implemented; **Retired** is
intentionally removed and retained only in feature history.

## Architecture

`flake.nix` is the configuration entrypoint and uses `flake-parts` for the
`x86_64-linux` per-system outputs. It imports `lib/internal/default.nix`, extends
`nixpkgs.lib` with the internal namespace, and passes the extended library through
`specialArgs`.

The shared NixOS core combines:

- `modules/nixos/default.nix`, which auto-discovers shared system modules;
- Home Manager as a NixOS module;
- nix-index integration; and
- shared Home Manager modules including the MCP registry bridge.

Host entrypoints live under `systems/x86_64-linux/`:

- `nixos` is the bare-metal graphical host. It owns hardware, EFI/systemd-boot, desktop,
  gaming, Podman, and its host-specific Noctalia Home Manager import.
- `nixos-wsl` is the WSL host. It owns the upstream NixOS-WSL import, disables graphical
  Home Manager defaults, and enables WSL-specific user behavior.

The upstream WSL module is intentionally absent from the shared core.

## Module Discovery and Internal Values

`lib.internal.scanPaths` imports all `.nix` files except `default.nix` plus directories
containing a `default.nix`. Both `modules/nixos/default.nix` and
`modules/home/default.nix` use this helper. Unit tests freeze the complete discovered
lists, so adding or removing a module requires an explicit expected-list update.

`lib/internal/default.nix` owns the configured identity, default editor and terminal,
theme flavor, system and Home Manager state versions, and discovery helper. Both state
versions are `26.05`. They remain fixed until an intentional, release-note-informed state
migration is specified.

## Home Manager and Agent Tooling

Home Manager owns user configuration and treats generated runtime files as read-only.
Shared defaults enable shells, CLI utilities, direnv, editors, terminal/session tools,
Codex, OpenCode, CodeGraph, Spec Kit, and the central MCP integration. GUI-aware modules
follow `internal.gui.enable`; the WSL host disables it.

Agent applications are selected explicitly from the pinned `llm-agents.nix` input.
Packaged MCP servers come from `mcp-servers-nix`; hosted servers remain explicit registry
entries. Local MCP commands resolve to Nix store binaries rather than `npx`, `uvx`, or
similar runtime resolvers. GitHub credentials are obtained by the GitHub MCP wrapper from
`gh auth token` instead of being exported at shell startup.

Codex consumes the generated Home Manager MCP configuration through a tested merge path
that keeps the user-owned `config.toml` writable. OpenCode reads `AGENTS.md`, the Spec Kit
constitution, and this document.

## Configuration, Caching, and Trust

Flake inputs are locked. Public nix-community, Numtide, and Noctalia caches accelerate
local builds; the `u3kkasha` Cachix cache is pushed by CI. Only `root` is trusted by the
Nix daemon. Wheel membership alone does not grant unsigned-NAR or cache privileges.

Podman is the sole container engine. Docker Engine is disabled, while Podman's
Docker-compatible CLI and system socket are enabled for projects that invoke `docker`.
Membership in the `podman` group therefore remains an intentional root-equivalent
privilege boundary pending a future hardening decision.

## Maintenance and Verification

Enter the developer environment with `nix develop`. Supported maintenance commands are:

```bash
nh os switch .
nh home switch .
nh clean all
nix fmt
nix flake check
```

The verification ladder is:

```bash
nix build .#checks.x86_64-linux.formatting --no-link
nix build .#unit-tests --no-link
nix build .#nixos-build .#nixos-wsl-build --no-link
nix build .#vm-test-nixos .#vm-test-wsl-mock
```

Formatting, unit assertions, and Gitleaks are flake checks. The pre-push hook runs the
flake checks and both host builds using pure evaluation. VM tests are intentionally CI
oriented because of their cost. CI also checks Spec Kit governance and periodically
builds important outputs with flake-configured extra caches disabled.

## Known Limitations and Planned Hardening

These are current limitations, not implemented capabilities. Their intended outcomes are
preserved in `specs/001-repository-hardening/spec.md`.

- The Podman Docker-compatible system socket and `podman` group grant root-equivalent
  access.
- The unit-test derivation realizes an integration-sized closure.
- Niri's resume command calls `hyprctl` instead of Niri's native monitor action.
- Shared Git identity values are declared but are not applied to Git configuration.
- Disabling GUI configuration still installs the pointer cursor package.
- nixd discards Nix string dependency context and relies on an implicit closure edge.
- Repeated Home Manager activation replaces the previous `.backup` recovery copy.
- Some physical-display configuration remains in a shared Home Manager module.
- Cache declarations are duplicated, unfree packages are broadly allowed, and one VM
  script hard-codes the configured username.

## Memory Update Contract

After implementation, the `speckit.system-memory.sync` hook MUST compare the delivered
behavior with this document. It updates capability status, architecture, commands,
policies, verification, and limitations only where the code now proves a different
reality. It removes a limitation only when its acceptance criteria pass. Historical
feature artifacts remain unchanged.
