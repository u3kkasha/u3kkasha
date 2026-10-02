# Implementation Plan: Clean Graphical Login

## Technical Context

- **System**: NixOS flake with shared NixOS modules and a bare-metal graphical host.
- **Current frontend**: tuigreet launched by `services.greetd`.
- **Target frontend**: ReGreet launched under Cage through greetd.
- **Boot behavior**: Kernel, udev, and systemd status output is controlled by kernel
  command-line parameters and remains journaled.
- **Affected files**: `modules/nixos/desktop/default.nix` and the canonical system
  memory document.

## Constitution Check

- Declarative ownership: pass; all behavior remains in NixOS modules.
- Shared boundaries: pass; the desktop module remains reusable and host-neutral.
- Security: pass; the existing `greeter` account and PAM boundary are retained.
- Verification: pass; formatting, configuration evaluation, and the display-manager
  VM check are required.
- Current-system memory: pass; the implemented greeter change will be synchronized.

## Design

1. Add quiet kernel parameters that disable routine systemd/udev console output while
   preserving journal diagnostics.
2. Replace the tuigreet command with the NixOS ReGreet module and a Cage session.
3. Keep Niri as the authenticated user's session command.
4. Verify the host configuration, formatting, and relevant VM checks.

## Verification Matrix

| Requirement                 | Verification                                        |
| --------------------------- | --------------------------------------------------- |
| Nix syntax and formatting   | `nix fmt -- --check` or repository formatting check |
| Host evaluation             | `nix build .#nixos-build --no-link`                 |
| Display manager integration | `nix build .#vm-test-nixos --no-link`               |
| Both-host regression        | `nix build .#configuration-tests --no-link`         |
