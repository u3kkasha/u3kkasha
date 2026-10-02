# Tasks: Clean Graphical Login

## Phase 1: Boot output

- [x] T001 [US1] Add quiet, systemd-status, initrd-systemd-status, and udev kernel parameters in `modules/nixos/desktop/default.nix`.
- [x] T002 [US1] Verify the graphical host evaluates with the boot-output change using `nix build .#nixos-build --no-link`.

## Phase 2: ReGreet frontend

- [x] T003 [US2] Replace the tuigreet greetd command with ReGreet under Cage while preserving the Niri session command in `modules/nixos/desktop/default.nix`.
- [x] T004 [US2] Verify formatting, host evaluation, configuration assertions, and the graphical VM display-manager check.
- [x] T005 [US2] Synchronize `.specify/memory/current-system.md` with the implemented graphical greeter.
