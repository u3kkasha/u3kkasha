# Research: Nix Module Cleanup

## Module arguments

- **Decision**: Preserve the built-in module-system `lib` and pass the repository helper
  set and Home Manager activation helper through separately named custom arguments.
- **Rationale**: Nixpkgs module-system documentation reserves `lib` for the Nixpkgs library
  and warns that custom `specialArgs.lib` reduces module interoperability.
- **Source**: [Nixpkgs Module System: Module arguments](https://nixos.org/manual/nixpkgs/unstable/#module-system-module-arguments).
- **Alternatives considered**: Keep extending `lib`; rejected because it overrides a
  reserved module argument. Put helpers in `_module.args`; rejected for the repository
  library because `scanPaths` is called while resolving `imports` and `_module.args` is not
  available at import time.

## Niri source organization

- **Decision**: Store the shared Niri config in a checked-in `.kdl` file with a valid
  comment marker that `niri.nix` replaces with the host-owned output block.
- **Rationale**: Native configuration text is easier to edit and review outside a Nix
  multiline string. The valid marker preserves the host block's existing generated-file
  position.
- **Alternatives considered**: Keep embedding the complete file in Nix; rejected because
  it obscures KDL syntax and dominates the module. Append the output block at the end;
  rejected to preserve its existing generated-file position.

## Home Manager package groups

- **Decision**: Move language/runtime and developer-specific tools to `devtools.nix`; keep
  general command-line programs and everyday utilities in `utils.nix`.
- **Rationale**: Toolchains such as Node.js, .NET, and DuckDB have a distinct maintenance
  purpose from general shell commands. Existing `internal.gui.enable` conditions remain
  with GUI utilities.
- **Alternatives considered**: Create a separate module for each package; rejected as
  unnecessary fragmentation. Change each package version or enabled state; out of scope.

## Flake derivation reuse

- **Decision**: Bind unit and configuration test derivations once inside `perSystem` and
  reuse those bindings for `packages` and `checks`.
- **Rationale**: Both output paths must continue exposing identical derivations; sharing
  the bindings removes duplicate declarations without changing public output names.
