# CONTEXT.md

## Project Overview

This repository contains a modular NixOS and Home Manager configuration specifically tailored for a WSL environment, now powered by `flake-parts`.

## Current State

- **NixOS Configuration**: Located in `default.nix` (within host-specific directories in `systems/`), manages system-level settings and modules.
- **Home Manager**: Integrated as a NixOS module, configured via `modules/home/default.nix`.
- **Shells**: Supports Bash and Nushell with proper integrations for all tools.
- **Environment Management**: Powered by `direnv` with `nix-direnv` for seamless project-specific developer environments.
- **Maintenance**: Maintenance tasks are centralized using `nh` (nix-helper), providing standardized commands for rebuilding the system/home configuration and performing garbage collection. This removes the need for custom wrapper scripts.
- **Binary Caching**: Cachix (`u3kkasha`) is integrated into CI (GitHub Actions) to speed up build verification.
- **Dynamic Imports (Scan Paths)**: The configuration imports system and user modules dynamically using a custom `scanPaths` helper, enabling auto-discovery of Nix files.
- **AI Tooling**: Agent applications come from the pinned `llm-agents.nix` package set, while `mcp-servers-nix` supplies packaged MCP servers through Home Manager's shared MCP registry.
- **Testing & Verification**: Leverages a suite of unit tests, `gitleaks` detection, and system-level VM integration tests (NixOS and WSL-mock) to ensure configuration safety.

## Key Decisions

- **Global Shell Setup**: Common tools and shell configurations are managed at the user level through Home Manager.
- **Devshell Integration**: Added `devshell` as a flake input and integrated it into the `devShells` output. This provides a rich interactive shell with built-in commands for project maintenance. Support for `direnv` auto-activation via `use flake` ensures seamless environment entry.
- **Transition to Direnv**: `devenv` has been replaced by `direnv` and `nix-direnv` to provide a more lightweight and standard way to activate developer shells.
- **Modularity (Dendritic Pattern)**: Configuration uses a custom `scanPaths` helper to automatically discover and import modules within `modules/` and `modules/home/`. This allows for a "dendritic" structure where adding a file to a directory automatically includes it in the configuration.
- **Discovery Contract Tests**: Unit tests freeze the discovered module lists for both NixOS and Home Manager so adding a module cannot silently alter either configuration tree.
- **Host-Scoped WSL Module**: The upstream NixOS-WSL module is imported only by the `nixos-wsl` host, not by the shared `nixosModules.core`.
- **Single Container Runtime**: Hosts select Podman as the only container runtime. Docker Engine is disabled, while Podman's Docker-compatible CLI and socket are enabled so project flakes that call `docker` continue to work against Podman.
- **Minimal Nix Trust**: Only `root` is a trusted Nix daemon user; wheel membership does not grant cache or unsigned-NAR privileges.
- **Host-Specific Entry Points**: Located in the `systems/` directory to support diverse environments (WSL, NixOS).
- **Explicit Agent Packages**: Codex, OpenCode, Antigravity, and Semble are selected directly from the locked `llm-agents.nix` input. They are not injected into nixpkgs with global package-replacement overlays.
- **Central MCP Registry**: Packaged MCP servers are declared through `mcp-servers-nix`; hosted servers remain explicit entries in `programs.mcp.servers`. Local MCP commands must resolve to packaged store binaries rather than runtime dependency resolvers. All MCP-aware clients consume the same Home Manager registry.
- **Scoped Credentials**: GitHub credentials are retrieved by the GitHub MCP wrapper with `gh auth token`; authentication tokens are not exported globally during shell startup.
- **Nushell Functions**: Multi-step maintenance commands in Nushell are defined as `def` functions instead of aliases to prevent accidental execution during shell initialization.
- **WSL Path Integration**: Windows paths are included in the Linux `PATH` to allow seamless interop with Windows binaries.
- **State Version Stability**: Decided to keep `stateVersion` fixed at `26.05` across all configurations. This field is a compatibility shim for stateful data and service defaults; updating it monthly would lead to unnecessary configuration churn and potential data format breakages. Users should only update it when they are prepared to perform manual migrations as detailed in NixOS release notes.
- **CI-only Cachix**: Cachix is only configured for the GitHub Actions pipeline to optimize CI minutes without adding local system overhead.
- **Pure Pre-Push Git Hooks**: A pre-push git hook is automatically configured in the devshell to run `nix flake check ./nix` and build both system configurations without allowing impure evaluation. This keeps local verification aligned with the locked flake.
- **CI-only Integration Tests**: Integration tests (`vm-test-nixos`, `vm-test-wsl-mock`) run full VM configurations and are resource-intensive. They are set up as package outputs to run automatically in CI, rather than block local git commit workflows.
- **Extra Substituters**: The `nixConfig` block in `flake.nix` configures additional public binary caches (nix-community, Numtide, noctalia) to speed up local builds by pulling pre-built artifacts where possible. The Numtide cache is used for `llm-agents.nix` packages built against that input's pinned nixpkgs.
