# AGENTS.md

This repository contains NixOS and Home Manager configuration files.

> [!IMPORTANT]
> Coding agents working on this project must read both this file ([AGENTS.md](file:///home/ukasha/code/.dotfiles/nix/AGENTS.md)) and [CONTEXT.md](file:///home/ukasha/code/.dotfiles/nix/CONTEXT.md) to align on the architecture, current state, and key decisions.

## Architecture

This project uses a modular NixOS configuration based on Flakes, `flake-parts`, and Home Manager.

### Structure

- `flake.nix`: Entry point for the Nix configuration, structured with `flake-parts`.
- `systems/`: Host-specific configurations (WSL, NixOS).
- `modules/`: Shared system-level modules, imported hierarchically.
- `modules/home/`: Shared user-level Home Manager modules.
- `lib/internal/`: Core logic and variables (username, email, stateVersion).
- `okf/`: Open Knowledge Format bundle documenting repository architecture, systems, modules, workflows, and policies for agent consumption.
- `AGENTS.md`: This file.
- `CONTEXT.md`: Project context and key decisions.

### Modularity Logic

- **Auto-Discovery**: This project uses a custom `lib.internal.scanPaths` function to automatically import all `.nix` files (excluding `default.nix`) and directories containing a `default.nix` within a given path.
- **Hierarchical Imports**: Modules are imported using this `scanPaths` logic in `modules/nixos/default.nix` and `modules/home/default.nix`.

## Binary Caching

- **Cachix**: Used for binary caching to speed up CI builds. The cache is named `u3kkasha`. CI builds push to this cache automatically. While currently omitted from the local `flake.nix` to keep the configuration minimal, it can be added to `nixConfig` if local uploads or prioritized pulls are needed.

## Configuration Management

- **Read-Only Files**: Most configuration files in `.config` (e.g., `lazygit/config.yml`) are managed by Home Manager and are symlinked to the Nix store. These files are **read-only**.
- **Modifying Config**: Do not attempt to modify these files directly or allow applications to "auto-migrate" them. All changes must be made in the corresponding Nix module (e.g., `modules/home/git.nix`) and applied via `nh os switch .` or `nh home switch .`.

## Workflow Commands

This project uses `nh` (nix-helper) for maintenance tasks. Enter the development shell (`nix develop`) to access these commands.

### Configuration Maintenance

- `nh os switch .`: Apply NixOS system configuration.
- `nh home switch .`: Apply Home Manager configuration.
- `nh clean all`: Perform garbage collection and cleanup of old generations.
- `nix fmt`: Format the entire repository.
- `nix flake check`: Check for formatting, linting issues, and secret leaks.

## State Version Policy

- **Policy**: The `systemStateVersion` and `homeStateVersion` (defined in `lib/internal/default.nix`) are set to `26.05` and should **not** be updated monthly.
- **Reasoning**: `stateVersion` is a compatibility shim, not a version for the configuration itself. It tells NixOS and Home Manager which "defaults" to use for stateful data (e.g., file formats, service defaults). Updating it without manual migration can cause subtle breakages or incompatible configuration formats.
- **Migration**: Only update this value when performing a major system overhaul or after carefully reading the NixOS/Home Manager release notes to identify required manual data migrations. Use the [NixOS Release Notes](https://nixos.org/manual/nixos/stable/release-notes) to check for "State Version" changes.

## Testing

Before finalizing changes, use the following commands to verify the configuration:

- **Unit Tests**: `nix build .#unit-tests` (Quick logic verification).
- **Integration Tests**:
  - `nix build .#vm-test-nixos` (Full NixOS system).
  - `nix build .#vm-test-wsl-mock` (WSL environment isolation).

## Code Style

- Use Nix flakes for dependency management.
- Modularize configuration into logical units under `nix/modules` using the `scanPaths` logic.
- Use `home-manager` for user-level configuration.
- **Commit Messages**: Follow the style `type(scope): 💡 description`.
- **Gitmoji**: Use Gitmojis to signify the intent of changes (e.g., ✨ for features, 🔧 for fixes, 🧪 for tests). Avoid using emojis involving humans or animals to maintain a clean and professional look.
- **Nushell Multi-command logic**: Prefer `def` functions over `alias` for multi-step commands to avoid immediate execution on shell startup.

## MCP Tools

- **Required MCP Servers**: The coding agent should use the `serena` MCP, `semble` MCP, and `nixos` MCP servers while working on this project.
- **Coordinating Semble and Serena**:
  - **Semble** (`search`, `find_related`): Use Semble first for broad, semantic, or natural-language searches to locate files and line numbers associated with a concept, configuration, or feature (e.g., searching for "home-manager package config" or "mcp configuration").
  - **Serena** (`find_symbol`, `find_referencing_symbols`, `replace_content`): Once Semble identifies the target file and lines, use Serena to query the AST/symbols, trace structural references, and perform precise, symbol-aware edits.
