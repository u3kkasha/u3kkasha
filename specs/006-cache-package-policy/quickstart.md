# Quickstart: Cache and Package Policy Validation

1. Run unit and generated-configuration checks.
2. Confirm flake and both daemon cache lists equal `lib.internal` values.
3. Confirm the unfree predicate accepts the three Steam-family names and rejects an unrelated name.
4. Confirm active Nix source contains no `allowUnfree = true` and each cache literal has one source.
5. Build both hosts and evaluate/build both VM derivations as resources permit.
