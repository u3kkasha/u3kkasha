# Quickstart: Desktop Boundary Validation

1. Build the quick and generated-configuration checks.
2. Confirm generated `hypridle.conf` contains `niri msg action power-on-monitors` and no `hyprctl`.
3. Confirm shared Niri source has no `eDP-1`, while the `nixos` generated KDL retains its mode and scale.
4. Confirm WSL pointer cursor is disabled and Bibata is absent from its Home Manager package closure.
5. Build both hosts and run the graphical VM test when resources permit.
