# Quickstart: Docker Runtime Validation

1. Run `nix build .#unit-tests --no-link` and the generated-configuration check named in the final implementation.
2. Run `nix build .#nixos-build .#nixos-wsl-build --no-link`.
3. Run `nix build .#vm-test-nixos .#vm-test-wsl-mock` when resources permit.
4. Confirm the assertions show Docker enabled, Podman absent, Compose available, and only the `docker` container group assigned.
5. Roll back to the previous system generation if runtime behavior is unacceptable; migrate any Podman workload state manually.
