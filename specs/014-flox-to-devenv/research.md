# Research: Replace Flox with devenv

## Decision

Use `pkgs.devenv` from the repository's existing nixpkgs input in the shared Home Manager
CLI module.

## Rationale

The configured hosts already share that package set and its lockfile. Current nixpkgs
provides the `devenv` attribute. This keeps one package source and avoids another flake
input or additional cache trust settings.

## Alternatives Considered

- Add the devenv upstream flake as a new input: unnecessary for installing the nixpkgs
  package and would expand the lock graph.
- Keep Flox alongside devenv: rejected because the requested environment CLI is devenv
  and Flox's local-only commits were explicitly removed.
- Replace the repository's flake dev shell: out of scope; it already supplies repository
  maintenance tools and hooks.
