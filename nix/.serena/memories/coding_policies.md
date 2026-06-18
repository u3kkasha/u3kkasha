# Coding Policies

- Most files under `.config` are Home Manager-managed symlinks into the Nix store and read-only. Do not edit generated config files directly; change the corresponding Nix module instead.
- Keep `systemStateVersion` and `homeStateVersion` fixed at `26.05` unless doing an explicit major migration after reading release notes.
- Prefer modular Nix files under the existing dendritic `modules/` and `modules/home/` structure.
- For Nushell multi-step commands, prefer `def` functions over aliases so commands do not execute at shell startup.
- Commit messages should follow `type(scope): 💡 description` and use professional gitmoji intent markers; avoid human/animal emojis.
