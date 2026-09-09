# Quickstart Validation: Full Headroom Integration

Run from the repository root. Initial builds are expected to be large because the feature includes
CPU Torch, ONNX Runtime, Transformers, and pinned local models.

```bash
nix build .#headroom --no-link
nix build .#unit-tests .#configuration-tests --no-link
nix build .#checks.x86_64-linux.formatting .#checks.x86_64-linux.actionlint --no-link
nix build .#nixos-build .#nixos-wsl-build --no-link
nix build .#vm-test-nixos .#vm-test-wsl-mock
```

The package check must initialize representative modules for every `[all]` group with network
disabled. Configuration tests must prove all clients receive the store command and that neither a
runtime resolver nor a global provider override exists. VM tests exercise the
[MCP contract](contracts/headroom-mcp.md). Validate the
[Codex launcher contract](contracts/codex-headroom.md) on the live host; full proxy startup is not
run under software-emulated QEMU because native ML/parser warmup can starve the readiness timer.

After successful verification:

```bash
nh os switch .
```

Use `codex`, `agy`, or `opencode` normally for direct provider traffic. Their MCP lists include
`headroom`. Use `codex-headroom` only when transparent request compression through the ephemeral
local proxy is desired. Antigravity transparent proxying is not configured.
