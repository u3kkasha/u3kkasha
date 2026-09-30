# Quickstart: Nix Module Cleanup

Run from the repository root after implementation.

1. Check formatting and configured source cleanup:

   ```bash
   nix fmt -- --ci
   ```

2. Check exact module discovery and internal helper assertions:

   ```bash
   nix build .#unit-tests --no-link
   ```

3. Evaluate generated configurations and package grouping on both hosts:

   ```bash
   nix build .#configuration-tests --no-link
   ```

4. Build the supported host systems:

   ```bash
   nix build .#nixos-build .#nixos-wsl-build --no-link
   ```

5. Run the full flake and repository governance checks:

   ```bash
   nix flake check
   .specify/scripts/bash/validate-project.sh
   ```

6. Run the integration VM derivations in CI:

   ```bash
   nix build .#vm-test-nixos .#vm-test-wsl-mock --no-link
   ```

Expected results: each command exits successfully, both test aliases remain available,
host outputs build, the WSL package set remains GUI-free, and generated Niri configuration
contains shared settings followed by only the bare-metal host's output block.
