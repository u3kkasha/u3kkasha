# Quickstart: Validate Shared Agent Instructions

From the repository root:

```bash
snip -- nix fmt -- --fail-on-change
snip -- nix build .#unit-tests --no-link
snip -- nix build .#configuration-tests --no-link
snip -- nix build .#nixos-build .#nixos-wsl-build --no-link
```

After activating a resulting generation, verify that `~/.codex/AGENTS.md` and
`~/.gemini/GEMINI.md` are identical and describe the environment as a Nix system.
