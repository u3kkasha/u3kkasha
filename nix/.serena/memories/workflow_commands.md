# Workflow Commands

Use the development shell (`nix develop`) for project maintenance commands.

Common commands:

- `nh os switch .`: apply NixOS system configuration.
- `nh home switch .`: apply Home Manager configuration.
- `nh clean all`: garbage collect old generations.
- `nix fmt`: format the repository.
- `nix flake check`: run checks, formatting/linting, and secret leak checks.
- `nix build .#unit-tests`: quick logic verification.
- `nix build .#vm-test-nixos`: full NixOS VM integration test.
- `nix build .#vm-test-wsl-mock`: WSL mock integration test.

Integration tests are resource-intensive and primarily intended for CI. CI uses Cachix cache `u3kkasha`.
