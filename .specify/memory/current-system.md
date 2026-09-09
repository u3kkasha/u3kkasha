# Current System

This document describes implemented reality for the Nix configuration. Source code and
executable checks remain the evidence; this file is the canonical prose projection of
that evidence. Update it only when implemented behavior changes.

## Capability Status

| Capability                    | Status            | Supported path                                                      | Verification                                       |
| ----------------------------- | ----------------- | ------------------------------------------------------------------- | -------------------------------------------------- |
| Bare-metal NixOS host         | Operational       | `nixosConfigurations.nixos`                                         | `nix build .#nixos-build`                          |
| WSL NixOS host                | Operational       | `nixosConfigurations.nixos-wsl`                                     | `nix build .#nixos-wsl-build`                      |
| Shared Home Manager layer     | Operational       | Home Manager as a NixOS module for the configured user              | `nix build .#configuration-tests`                  |
| Automatic module discovery    | Operational       | `lib.internal.scanPaths` for NixOS and Home Manager trees           | Exact discovered-path unit tests                   |
| Docker container runtime      | Operational       | Conventional rootful Docker Engine and Compose v2                   | Configuration assertions and both VM/build targets |
| Central MCP registry          | Operational       | `programs.mcp.servers` shared by MCP-aware clients                  | Generated-configuration unit assertions            |
| Full Headroom integration     | Operational       | Pinned `[all]` package, shared MCP tools, and opt-in Codex proxy    | `nix build .#headroom-tests` and both VM targets   |
| Local developer workflow      | Operational       | Flake dev shell, `nh`, treefmt, Actionlint, Gitleaks, and Git hooks | `nix flake check`                                  |
| VM integration verification   | Operational in CI | Bare-metal and WSL-mock test derivations                            | `nix build .#vm-test-nixos .#vm-test-wsl-mock`     |
| Spec-driven change governance | Operational       | Spec Kit Codex skills, Nix templates, and system-memory hook        | `.specify/scripts/bash/validate-project.sh`        |

Status vocabulary: **Operational** is supported and verifiable; **Partial** works with a
documented limitation; **Planned** is accepted but not implemented; **Retired** is
intentionally removed and retained only in feature history.

## Architecture

`flake.nix` is the configuration entrypoint and uses `flake-parts` for the
`x86_64-linux` per-system outputs. It imports `lib/internal/default.nix`, extends
`nixpkgs.lib` with the internal namespace, and passes the extended library through
`specialArgs`.

The shared NixOS core combines:

- `modules/nixos/default.nix`, which auto-discovers shared system modules;
- Home Manager as a NixOS module;
- nix-index integration; and
- shared Home Manager modules including the MCP registry bridge.

Host entrypoints live under `systems/x86_64-linux/`:

- `nixos` is the bare-metal graphical host. It owns hardware, EFI/systemd-boot, desktop,
  gaming, Docker, its physical Niri output, and its host-specific Noctalia Home Manager import.
- `nixos-wsl` is the WSL host. It owns the upstream NixOS-WSL import, disables graphical
  Home Manager defaults, and enables WSL-specific user behavior including GNOME Keyring,
  libsecret, and Seahorse.

The upstream WSL module is intentionally absent from the shared core.

## Module Discovery and Internal Values

`lib.internal.scanPaths` imports all `.nix` files except `default.nix` plus directories
containing a `default.nix`. Both `modules/nixos/default.nix` and
`modules/home/default.nix` use this helper. Unit tests freeze the complete discovered
lists, so adding or removing a module requires an explicit expected-list update.

`lib/internal/default.nix` owns the configured username, default editor and terminal,
theme flavor, cache projection, exact unfree-package policy, system and Home Manager state
versions, and discovery helper. Git name and email are intentionally repository-local rather
than global. Both state versions are `26.05`. They remain fixed until an intentional,
release-note-informed state migration is specified.

## Home Manager and Agent Tooling

Home Manager owns user configuration and treats generated runtime files as read-only.
Shared defaults enable shells, CLI utilities, direnv, editors, terminal/session tools,
Codex, OpenCode, Antigravity CLI, CodeGraph, Spec Kit, the Vercel Skills CLI, and the
central MCP integration.
GUI-aware modules follow `internal.gui.enable`; the WSL host disables it, including pointer
cursor configuration and the Bibata cursor package.

The reusable Niri module owns compositor behavior but no physical output identity. The
bare-metal host supplies its `eDP-1` mode and scale through the module's host fragment. Niri's
idle resume action uses `niri msg action power-on-monitors`.

Agent applications are selected explicitly from the pinned `llm-agents.nix` input.
Packaged MCP servers come from `mcp-servers-nix`; hosted servers remain explicit registry
entries. Local MCP commands resolve to Nix store binaries rather than `npx`, `uvx`, or
similar runtime resolvers. GitHub credentials are obtained by the GitHub MCP wrapper from
`gh auth token` instead of being exported at shell startup.

Headroom 0.36.0 is built from a pinned source and Cargo lock with its official `[all]`
capability closure. Private Python overrides keep the package compatible without changing the
global nixpkgs package set. Default Kompress, routing, image, embedding, and tokenizer assets are
fixed Nix derivations exposed through read-only Hugging Face and tiktoken caches; runtime model
downloads are disabled. The package wrapper also supplies the `ast-grep`, `difft`, and `scc`
helper binaries from the store. `headroom-tests` imports every bundled dependency group and runs
the real Kompress ONNX and local embedding models with build-sandbox networking disabled.

The central registry launches `headroom mcp serve` for Codex, OpenCode, and Antigravity CLI.
Its mutable state is user-scoped under XDG config/data directories, and MCP compression and exact
retrieval work without a running proxy. The shared savings ledger path (`HEADROOM_SAVINGS_EVENTS_PATH`)
is declared in the user session and explicitly exported by the launcher so `headroom savings`
reports unified history. `codex-headroom` is a separate opt-in command: it creates a temporary
Headroom home and memory database, starts a `127.0.0.1:8787` proxy, waits for health, passes Codex a
process-local `openai_base_url`, and removes the proxy and temporary state when Codex exits,
preserving only the shared savings ledger. Normal `codex`, `agy`, and `opencode` commands retain
direct provider routing.

Codex consumes the generated Home Manager MCP configuration through a tested merge path
that keeps the user-owned `config.toml` writable. OpenCode and Antigravity CLI also consume
the central MCP registry through their Home Manager integrations; Antigravity's integration
generates `~/.gemini/config/mcp_config.json`. OpenCode reads `AGENTS.md`, the Spec Kit
constitution, and this document. nixd generates its locked-input configuration through a
reference-bearing derivation, so the locked-input link farm is an explicit closure dependency;
no string context is discarded.

## Configuration, Caching, and Trust

Flake inputs are locked. `lib/internal/cache.nix` is the single source for the public
nix-community, Numtide, and Noctalia daemon caches. Pull-request CI consumes the public
`u3kkasha` Cachix cache without credentials or publishing; only trusted default-branch push and
manual jobs receive its write token. Read-only CI checkouts do not persist GitHub credentials.
Only `root` is trusted by the Nix daemon. Wheel membership alone does not grant
unsigned-NAR or cache privileges. Unfree evaluation is limited to the exact Steam package
family: `steam`, `steam-original`, and `steam-unwrapped`.

Headroom external telemetry, OpenTelemetry export, update checks, and runtime model-network access
are disabled by default. The opt-in Codex proxy has no persistent service or global provider URL;
it receives existing Codex credentials only in process and binds only to loopback. No credential,
trust, unfree-policy, state-version, or host-boundary change accompanies the integration.

GitHub repository policy requires full commit-SHA Action references and permits GitHub-owned
Actions plus only the checked-in Determinate Systems, Cachix, and Gitleaks Actions. Dependabot
security updates, secret scanning with push protection, and weekly CodeQL default analysis for
GitHub Actions and Python are enabled. The default-branch ruleset requires the aggregate `CI Gate`
status with strict branch freshness.

Docker is the sole container engine. Both hosts enable the conventional rootful Docker daemon
and Compose v2; Podman is not enabled or installed by the configuration. The configured user is
in the `docker` group. This is an explicitly accepted root-equivalent privilege boundary chosen
for maximum Compose, privileged-container, device, and networking compatibility. Podman runtime
state is not migrated automatically.

## Maintenance and Verification

Enter the developer environment with `nix develop`. Supported maintenance commands are:

```bash
nh os switch .
nh home switch .
nh clean all
nix fmt
nix flake check
```

The verification ladder is:

```bash
nix build .#checks.x86_64-linux.formatting --no-link
nix build .#checks.x86_64-linux.actionlint --no-link
nix build .#unit-tests --no-link
nix build .#configuration-tests --no-link
nix build .#headroom-tests --no-link
nix build .#nixos-build .#nixos-wsl-build --no-link
nix build .#vm-test-nixos .#vm-test-wsl-mock
```

Formatting, Actionlint, quick source/internal-library unit assertions, generated-configuration
assertions, and Gitleaks are flake checks. Actionlint is supplied by the pinned package set and
validates the repository-root GitHub workflows; the pre-commit hook runs it beside formatting and
Gitleaks. `unit-tests` is the quick target. `configuration-tests` evaluates both supported hosts,
generated files, package closures, and the Codex merge path, so it has medium-to-heavy closure cost.
`headroom-tests` is an integration-sized offline model and MCP check; its initial closure includes
CPU PyTorch, ONNX Runtime, Transformers, and multiple pinned model snapshots.
The pre-push hook runs the flake checks and both host builds using pure evaluation. VM tests are
intentionally CI oriented because of their cost.

CI jobs have explicit timeouts, and the lock updater serializes access to its shared update branch.
Required evaluation plus all four system/VM matrix builds feed the failure-aware `CI Gate` required
by the default-branch ruleset. Automated lock-update PRs publish an `nvd` bare-metal closure diff in
the run summary. CI also checks Spec Kit governance and builds important outputs monthly and on
manual dispatch using only the official Nix cache.

## Known Limitations and Planned Hardening

These are current limitations, not implemented capabilities. Their intended outcomes are
preserved in `specs/001-repository-hardening/spec.md`.

- Repeated Home Manager activation replaces the previous `.backup` recovery copy.
- Antigravity CLI receives Headroom's complete MCP tool integration, but its Cloud Code provider
  traffic is not routed through the transparent proxy because that protocol is not a supported
  Headroom proxy target.
- A first `codex-headroom` launch may spend roughly two minutes warming the complete local
  ML/parser stack on CPU before Codex starts. Software-emulated VM tests therefore verify MCP
  integration but do not run the full proxy launcher; its health, cleanup, and config immutability
  are smoke-tested on the live host.

## Memory Update Contract

After implementation, the `speckit.system-memory.sync` hook MUST compare the delivered
behavior with this document. It updates capability status, architecture, commands,
policies, verification, and limitations only where the code now proves a different
reality. It removes a limitation only when its acceptance criteria pass. Historical
feature artifacts remain unchanged.
