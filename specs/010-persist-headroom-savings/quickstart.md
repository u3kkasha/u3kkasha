# Quickstart: Validate Persistent Headroom Savings

## Prerequisites

- Run from the repository root on `x86_64-linux`.
- Use the pinned flake inputs; no network-backed runtime model download is required.

## Validate formatting and generated configuration

```bash
nix build .#checks.x86_64-linux.formatting --no-link
nix build .#configuration-tests --no-link
```

Expected outcome: both builds succeed. Configuration tests prove both host launchers select
the shared XDG savings ledger while retaining the temporary workspace and cleanup controls.

## Validate ledger behavior

```bash
nix build .#headroom-tests --no-link
```

Expected outcome: the offline Headroom integration suite succeeds, including a savings
event that remains reportable after its temporary workspace is deleted.

## Inspect savings after activation

After using `codex-headroom`, run:

```bash
headroom savings
```

Expected outcome: wrapped Codex compression events appear alongside Headroom MCP events in
the lifetime and applicable time-window totals.

Stop active Headroom MCP/proxy processes before using `headroom savings --reset`.

## Delegated host verification

CI performs the heavier shared-host builds:

```bash
nix build .#nixos-build .#nixos-wsl-build --no-link
```
