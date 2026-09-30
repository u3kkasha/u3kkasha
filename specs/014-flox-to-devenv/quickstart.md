# Quickstart Validation

From the repository root, evaluate the configured package lists for both hosts:

```sh
nix eval --json .#nixosConfigurations.nixos.config.home-manager.users.ukasha.home.packages --apply 'builtins.map (p: p.name)'
nix eval --json .#nixosConfigurations.nixos-wsl.config.home-manager.users.ukasha.home.packages --apply 'builtins.map (p: p.name)'
```

Confirm each result includes a devenv package. Format the Nix source with the repository
formatter and ensure both host configurations evaluate successfully.
