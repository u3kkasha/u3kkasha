# Quickstart: Bare-Metal Desktop Rebuild

1. Review the generated NixOS and Home Manager evaluation without activation:

   ```bash
   nix build .#nixos-build --no-link
   nix build .#configuration-tests --no-link
   ```

2. Confirm the flake exposes both project cache hints and that the Niri/Noctalia package
   outputs are selected by the bare-metal host.

3. Build the WSL host to verify it remains headless:

   ```bash
   nix build .#nixos-wsl-build --no-link
   ```

4. If all checks pass, activate only after reviewing the generated desktop configuration:

   ```bash
   nh os switch .
   ```

5. Roll back through the normal NixOS generation selector if the graphical session fails.
