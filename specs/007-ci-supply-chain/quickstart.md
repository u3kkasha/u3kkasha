# Quickstart: Validate CI Supply-Chain Hardening

## Local validation

From the repository root:

```bash
actionlint .github/workflows/*.yml
cd nix
nix fmt -- --ci
nix flake check .
.specify/scripts/bash/validate-project.sh
```

Inspect the diff and confirm no state-version or host module source changed.

## Live-setting validation

```bash
gh api repos/u3kkasha/u3kkasha/actions/permissions
gh api repos/u3kkasha/u3kkasha/actions/permissions/selected-actions
gh api repos/u3kkasha/u3kkasha/code-scanning/default-setup
gh api repos/u3kkasha/u3kkasha/rulesets/17533543
```

The first query must report selected Actions and required SHA pinning. The second must list only the
approved third-party patterns in addition to GitHub-owned Actions. CodeQL must be configured for the
detected supported languages.

## Post-push gate activation

After pushing the commit, open or update a pull request and wait for the `CI Gate` check to appear.
Add that exact context as a required status check to ruleset `17533543`, then query the ruleset and
confirm the requirement. Do not activate the context before the workflow is remotely available.

## Rollback

Remove the required context before reverting a workflow that defines `CI Gate`. Revert the commit,
then restore Actions permissions or disable native security features only if they caused the issue.
