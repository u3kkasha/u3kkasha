# Research: CI Supply-Chain Hardening

## Baseline observations

- The active default-branch ruleset `17533543` required pull requests, linear history, and protected
  deletion/non-fast-forward behavior, but contained no required status check.
- Verification run `33709860962` for automated lock-update PR `#25` failed before creating jobs; the
  pull request nevertheless merged because no check was required.
- Repository Actions permissions allowed all Actions and reported `sha_pinning_required: false`.
- Dependabot security updates were disabled because vulnerability alerts were not enabled.
- Secret scanning and push protection were enabled and must remain enabled.
- CodeQL default setup was not configured; GitHub detected `actions` and `python` as supported
  repository languages.
- Neither checked-in workflow declared job timeouts; the updater had no concurrency group; and
  official-cache-only builds were manual-only.
- All ten functional requirements, four invariants, five success criteria, and the security boundary
  map to tasks T003–T018; no implementation requirement is uncovered.

## Decision: Use one aggregate required-check context

**Rationale**: Matrix check names are generated and can change as targets change. A final job with a
stable display name can inspect the complete required dependency results and gives the ruleset one
durable context. Running it under `always()` makes failures and cancellations observable.

**Alternatives considered**: Requiring each matrix check directly was rejected because it couples
repository settings to matrix labels. Requiring only the evaluation check would leave host and VM
failures mergeable.

## Decision: Authenticate Cachix only for trusted events

**Rationale**: Public caches can be consumed without the write token. Restricting authentication to
default-branch pushes and explicit manual runs preserves publishing while minimizing PR credentials.

**Alternatives considered**: Passing an empty secret to every event was rejected because the trust
boundary would be implicit. Disabling Cachix entirely on PRs would unnecessarily lose public cache
downloads.

## Decision: Reuse the existing build matrix for dependency impact

**Rationale**: The bare-metal matrix leg already constructs the proposed system. It can additionally
build the base revision and run the locked dev-shell `nvd`, placing output in the run summary without
new write permissions.

**Alternatives considered**: A PR comment needs additional write permission. A separate comparison
job repeats both system builds. Lockfile-only reporting cannot show package-level closure changes.

## Decision: Separate scheduled cache-independent execution logically

**Rationale**: The existing workflow can run monthly while event conditions suppress ordinary jobs
for scheduled events. Manual dispatch continues to run both ordinary and cache-independent paths.

**Alternatives considered**: A third workflow duplicates Action setup and policy. Running all jobs
on schedule duplicates the important host builds.

## Decision: Stage repository-setting rollout

**Rationale**: SHA enforcement, publisher restriction, security updates, and CodeQL are safe with the
current remote workflows. Requiring `CI Gate` before that workflow is pushed could make every remote
PR unmergeable, so ruleset activation is a post-push step.

**Alternatives considered**: Pushing was excluded by the user's request. Requiring the old matrix
checks temporarily adds ruleset churn without eliminating the deployment-order constraint.
