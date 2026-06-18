---
type: Home Manager Module Layer
title: Shared Home Manager Modules
description: User-level module layer that sets defaults for shells, tools, editor, terminal, and GUI-aware modules.
resource: ../../modules/home/default.nix
tags: [home-manager, modules, user-config]
timestamp: 2026-06-18T00:00:00+06:00
---

# Shared Home Manager Modules

`modules/home/default.nix` imports user-level modules discovered by [/architecture/module-auto-discovery](/architecture/module-auto-discovery.md), defines internal Home Manager options, and sets default enablement for common tools.

The layer sets `home.username`, `home.homeDirectory`, default editor session variables, the Home Manager state version, and Catppuccin theme defaults. It enables common modules by default, including Bash, CLI tooling, direnv, Codex, git, Helix, Nushell, opencode, nixd, Yazi, and Zellij.

GUI-aware modules such as Ghostty and Niri default to the `internal.gui.enable` option. The [/systems/nixos-wsl](/systems/nixos-wsl.md) host disables GUI configuration for its Home Manager user settings.

# Citations

[1] [modules/home/default.nix](../../modules/home/default.nix)
[2] [systems/x86_64-linux/nixos-wsl/default.nix](../../systems/x86_64-linux/nixos-wsl/default.nix)
[3] [README.md](../../README.md)
