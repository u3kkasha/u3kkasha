# Quickstart: Validate Root Flake Layout

Run all commands from the Git repository root.

## 1. Confirm the root boundary

```bash
nix flake metadata .
test -f README.md
test -f LICENSE
test -f flake.nix
test -f flake.lock
test ! -e nix/flake.nix
```

Expected: metadata resolves the root flake, public files remain, and no nested entrypoint exists.

## 2. Prove Actionlint purity and coverage

```bash
actionlint .github/workflows/*.yml
nix build .#checks.x86_64-linux.actionlint --no-link
nix build 'path:.#checks.x86_64-linux.actionlint' --no-link
```

Expected: all commands succeed without `--impure`; Actionlint reports zero errors for both tracked
workflow files.

## 3. Run repository verification

```bash
nix fmt
nix flake check --no-build
nix build .#unit-tests .#configuration-tests --no-link
.specify/scripts/bash/validate-project.sh
```

Expected: formatting, evaluation, quick tests, generated configuration, and governance pass.

## 4. Verify supported hosts

```bash
nix build .#nixos-build .#nixos-wsl-build --no-link
```

Expected: both supported host closures build from the root flake.

## 5. Check relocation integrity

```bash
git status --short
git diff -- README.md LICENSE
rg -n --hidden -S '\./nix|dir=nix|path-to-flake-dir' . \
  --glob '!.git/**' --glob '!specs/00[1-8]-*/**'
```

Expected: Git reports moves/targeted edits, the public files have no content diff, and no active
configuration or documentation retains the nested-flake invocation.
