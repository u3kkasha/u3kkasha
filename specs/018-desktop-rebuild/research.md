# Research: Bare-Metal Desktop Rebuild

## Decisions

### Use `sodiboo/niri-flake` for Niri

The upstream project provides NixOS and Home Manager modules, structured
`programs.niri.settings`, build-time configuration validation, and a public
`niri.cachix.org` cache. Its documented public key is
`niri.cachix.org-1:Wv0OmO7PsuocRKzfDoJ3mulSl7Z6oezYhGhR+3W2964=`. The module can provide
the Niri package and session integration; the existing custom polkit/portal setup must be
compared against the module to avoid duplicate services.

Source: https://github.com/sodiboo/niri-flake

### Keep the Noctalia project flake package

The Noctalia flake exposes a Home Manager module that sets
`programs.noctalia.package` to its own package output. This preserves the project’s
`noctalia.cachix.org` cache and avoids the mismatch between the project’s shell and a
nixpkgs package. Home Manager should own the package; the system package duplicate should
be removed.

Source: https://github.com/noctalia-dev/noctalia/blob/main/flake.nix

### No Stylix or DankMaterialShell

Noctalia remains the desktop theme authority. Stylix would overlap with Noctalia’s runtime
GTK/template theming, and DankMaterialShell introduces a separate shell and Niri integration
path that is outside the requested lean design.

### Preserve existing user tooling and infrastructure

Docker, gaming, development tools, MCP registry/server infrastructure, WSL, and existing
CLI/agent applications remain in scope. The desktop rebuild must not prune the user profile.

## Risks and mitigations

- Niri-flake may enable functionality already configured by the repository; inspect its
  module and disable duplicate services rather than blindly retaining both.
- The project package tracks newer upstream dependencies than nixpkgs; evaluate the pinned
  lock before building and keep the previous generation available for rollback.
- Existing agent applications and shared instruction generators must remain intact while
  desktop ownership changes are made.
