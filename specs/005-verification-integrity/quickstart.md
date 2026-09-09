# Quickstart: Verification Integrity

1. Run `nix build .#unit-tests --no-link`; this is the quick target.
2. Run `nix build .#configuration-tests --no-link`; expect supported-host/generated closure cost.
3. Run `nix flake check --no-build` and both host builds.
4. Evaluate or build both VM derivations as resources allow.
5. Confirm active source contains neither `unsafeDiscardStringContext` nor a literal configured username in VM scripts.
