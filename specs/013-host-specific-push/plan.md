# Implementation plan

Use the hostname, with `NIXOS_HOST` override, to select one host build in the existing
pre-push hook. Keep formatting, Actionlint, unit assertions, and Gitleaks as shared checks.
Do not run the all-host `nix flake check` from the hook because its configuration check
evaluates and builds closure assertions for both hosts. Keep cross-host configuration
assertions and VM tests in CI. Update current-system memory to document the changed local
verification behavior.

## Verification

- Inspect the generated hook expression and confirm the two host mappings and error path.
- Run formatter and relevant Nix evaluation checks; full host builds are delegated to the
  pre-push hook and CI.
