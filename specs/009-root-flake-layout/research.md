# Research: Root Flake Layout

## Decision 1: Use the Git repository root as the flake root

**Baseline evidence**: Before relocation,
`nix build ./nix#checks.x86_64-linux.actionlint --no-link` passed and direct Actionlint
reported zero errors in two workflow files. In contrast,
`nix build 'path:./nix#checks.x86_64-linux.actionlint' --no-link` failed because pure
evaluation attempted to access `/nix/store/.github/workflows`; adding `--impure` still
failed because the parent `.github` directory was absent from the copied path source.

**Decision**: Relocate the existing flake and all tracked configuration children to the Git
repository root.

**Rationale**: GitHub requires workflows under root `.github/workflows`. Putting the flake at
the same boundary makes workflow sources available to both Git-aware and explicit path inputs,
and removes special `./nix`/`dir=nix` invocation paths.

**Alternatives considered**:

- Keep the nested flake and add the workflows as another input: adds source/lock complexity
  solely to compensate for the split boundary.
- Duplicate workflows under `nix/`: creates two authorities and does not affect the workflows
  GitHub actually executes.
- Require Git-aware evaluation or `--impure`: fragile for archives/path inputs; `--impure` does
  not restore a directory omitted from the path source.

## Decision 2: Preserve public root metadata alongside the flake

**Decision**: Keep `README.md`, `LICENSE`, `.github/`, and repository-wide `.gitignore` at root;
merge only non-conflicting ignore patterns from `nix/.gitignore`.

**Rationale**: GitHub renders the root README regardless of a flake's presence. These files are
compatible with a root flake and several are operationally required at that location.

**Alternatives considered**:

- Move or rename the README: breaks the profile repository's public presentation.
- Keep only Nix files at root: unnecessary; flakes are normal mixed-content repositories.

## Decision 3: Relocate tracked source, not runtime artifacts

**Decision**: Use Git-aware moves for tracked content. Do not add ignored result links, `.direnv`,
CodeGraph databases/logs, Serena caches/local settings, Spec Kit caches, or generated hook links.

**Rationale**: The constitution distinguishes declarative source from generated runtime state.
Keeping ignored artifacts out avoids accidental machine-local state becoming repository policy.

**Alternatives considered**:

- Move the directory wholesale: risks mixing generated state with declarative source and creates
  collisions with root-local tooling directories.
- Delete all ignored state: unnecessary and destructive; it may be regenerated or cleaned later.

## Decision 4: Treat historical specs as immutable history

**Decision**: Update active source, current-system memory, current feature artifacts, and current
instructions. Do not rewrite completed feature directories `001` through `008` merely to replace
historical paths.

**Rationale**: The constitution says completed feature artifacts preserve history and do not
override current source or canonical memory.

**Alternatives considered**:

- Mechanically rewrite all old specs: creates noisy historical changes and misrepresents the
  commands and design used at the time.

## Decision 5: Verification depth

**Decision**: Prove root and `path:.` Actionlint behavior, run formatting/governance and quick
configuration tests, and build both host outputs. Leave VM integration behavior unchanged.

**Rationale**: This crosses CI and agent-tooling layers and affects both hosts' source paths, but
does not change runtime composition. Both host builds establish closure integrity; VM tests would
repeat unchanged runtime behavior at disproportionate cost.

**Alternatives considered**:

- Only run Actionlint: insufficient for a repository-wide relocation.
- Run both VM tests locally: valid but not the least expensive proof for path-only changes.
