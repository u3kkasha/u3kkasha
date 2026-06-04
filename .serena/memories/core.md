# Core Source Map

Modular NixOS and Home Manager configuration for personal dotfiles, optimized for WSL and standard NixOS.

## Domain Entry Points

- `flake.nix`: Root configuration using `flake-parts`.
- `systems/x86_64-linux/`: Host-specific configurations (`nixos`, `nixos-wsl`).
- `modules/`: Shared logic.
    - `modules/nixos/`: System-level modules.
    - `modules/home/`: User-level Home Manager modules.
- `lib/internal/`: Core logic, variables, and constants.

## System Invariants

- Namespace: `internal` (custom lib extension).
- User: `ukasha` (`mem:tech_stack`).
- State Version: `26.05`.
- Theme: `catppuccin` (mocha).

## See Also

- Build & Tools: `mem:tech_stack`
- Workflow: `mem:suggested_commands`
- Guidelines: `mem:conventions`
- Done Criteria: `mem:task_completion`
