# Conventions

## Configuration Structure

- **Module Pattern**: Modules provide an `internal.<name>.enable` option, defaulting to `true` or tied to `internal.gui.enable`.
- **Custom Lib**: Project-specific functions and constants are exposed via `lib.internal`.
- **Read-Only Config**: HM-managed files in `.config` are symlinked from the Nix store. **Never modify directly.**

## Code Style

- **Nix**: Modularize into logical units. Use `inherit` for clarity.
- **Nushell**: Use `def` for multi-step commands instead of `alias` to prevent execution during shell startup.
- **Commit Messages**: Follow `type(scope): description` format (e.g., `feat(git): add useful aliases`).

## System Isolation

- **WSL Path Isolation**: Windows binaries are explicitly excluded from the Linux `PATH` to prevent shadowing.
