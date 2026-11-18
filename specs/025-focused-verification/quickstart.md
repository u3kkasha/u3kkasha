# Focused Verification Quickstart

The change does not alter either host configuration. CI is the execution environment for
the host builds and VM runtime checks.

## Configuration and policy checks

```bash
nix build .#unit-tests .#configuration-tests --no-link
```

Expected: module-discovery and explicit security/reproducibility policy assertions pass;
the configuration derivation checks generated Codex merge behavior without parsing nixd
JSON in the evaluator.

## Generated host output

```bash
nix build .#nixos-build .#nixos-wsl-build --no-link
```

Expected: both host outputs evaluate and build with the nixd module and locked-input path
closure intact.

## Runtime integration

```bash
nix build .#vm-test-nixos .#vm-test-wsl-mock
```

Expected: Docker is active and usable by the configured user on both VM targets.

## Execution status

These commands were not run during this edit. The source changes were reviewed, and CI
should run the configuration checks, both host builds, and VM derivations.
