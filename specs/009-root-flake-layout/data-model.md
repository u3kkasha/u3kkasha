# Data Model: Root Flake Layout

This feature has no application data model. Its relevant entities are repository artifacts and
their ownership relationships.

## Repository Root

**Identity**: Git worktree root.

**Owned tracked artifacts**:

- Public metadata: `README.md`, `LICENSE`, `.gitignore`
- GitHub automation: `.github/`
- Nix entrypoints: `flake.nix`, `flake.lock`, `treefmt.nix`
- Configuration: `lib/`, `modules/`, `packages/`, `systems/`, `tests/`
- Governance and tooling: `AGENTS.md`, `.agents/`, `.codex/`, `.specify/`, `specs/`, `docs/`, `okf/`
- Development entrypoint: `.envrc`

**Validation rules**:

- There is exactly one active flake entrypoint and lock at the repository root.
- Root public metadata remains tracked.
- `.github/workflows` is inside the flake source boundary.
- No active tracked source depends on a `nix/` prefix.

## Flake Source Boundary

**Identity**: The source tree presented to Nix for `.` or `path:.`.

**Relationships**:

- Contains the repository root artifacts needed by checks.
- Supplies both supported host configurations and all existing check/package outputs.
- Contains `.github/workflows`, which the Actionlint derivation consumes.

**State transition**:

1. Nested boundary: `nix/` is the flake while workflows are its sibling.
2. Relocation in progress: tracked content is moved and references are updated atomically.
3. Root boundary: the repository root is the flake and contains workflows.

## Runtime/Generated Artifacts

**Examples**: `.direnv/`, `result*`, CodeGraph database/log files, Serena cache/local settings,
Spec Kit extension cache, generated `.pre-commit-config.yaml` links.

**Validation rules**:

- Remain ignored.
- Are not promoted into the tracked root configuration.
- May coexist locally but are not required for evaluation.
