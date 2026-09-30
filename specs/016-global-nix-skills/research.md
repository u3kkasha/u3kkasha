# Research: Global Nix Skills

- Decision: Use `olafkfreund/nix-skills` through its Home Manager module.
  - Rationale: It curates source-backed Nix, NixOS, Home Manager, Nixpkgs, and devenv guidance and provides native agent directories.
  - Alternatives considered: `z1-0/skills-nix` provides a broader general-purpose skills catalog, but adds a general installer where the request is specifically for Nix guidance.
- Decision: Select `nix-language`, `nix-workflow`, `nixpkgs-development`, `nixos-operations`, `home-manager`, and `devenv-project` for Codex and OpenCode.
  - Rationale: These cover the user's Nix coding, NixOS configuration, Home Manager, and devenv workflows; specialist microVM, nix-darwin, and agent sandbox skills are outside current host scope.
- Decision: Keep `llm-agents.nix`'s `skills` package.
  - Rationale: It supports discovery and project-level use; the upstream Nix module handles reproducible global installation.
