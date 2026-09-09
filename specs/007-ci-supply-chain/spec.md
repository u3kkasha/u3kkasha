# Feature Specification: CI Supply-Chain Hardening

**Feature Directory**: `007-ci-supply-chain`

**Created**: 2026-09-08

**Status**: Approved

**Input**: "Harden the repository's DevOps workflow, verification gates, dependency automation, credentials, and GitHub security settings."

## Intent and Scope _(mandatory)_

### Problem

Pull requests can currently merge without successful verification, pull-request jobs receive
a cache write credential, jobs have no explicit execution bounds, cache-independent builds are
manual-only, and automated dependency changes provide input revisions without a system-package
impact summary. Repository settings permit unpinned or unapproved Actions despite the checked-in
workflows already using immutable revisions.

### Desired Outcome

Every pull request is subject to a stable required verification result, untrusted change
evaluation has read-only credentials, CI work is bounded and non-overlapping, dependency updates
show their package impact, cache independence is checked periodically, and repository security
settings enforce the checked-in supply-chain policy.

### Out of Scope

- Automatically merging dependency pull requests.
- Deploying or activating either NixOS host from CI.
- Changing NixOS, Home Manager, or application package configuration.
- Adding self-hosted runners or new paid services.

## Affected Targets _(mandatory)_

| Target or layer                  | Affected? | Expected observable change                                                            |
| -------------------------------- | --------- | ------------------------------------------------------------------------------------- |
| `nixos` host                     | No        | No host configuration change                                                          |
| `nixos-wsl` host                 | No        | No host configuration change                                                          |
| Shared NixOS modules             | No        | N/A                                                                                   |
| Shared Home Manager modules      | No        | N/A                                                                                   |
| Developer shell or agent tooling | Yes       | Workflow linting joins the declarative developer checks and pre-commit hook           |
| CI, caching, or verification     | Yes       | Required, bounded, credential-minimized verification and hardened repository settings |

## User Scenarios & Testing _(mandatory)_

### User Story 1 - Prevent Unverified Merges (Priority: P1)

As the repository operator, I need every proposed change to produce one stable aggregate result
that cannot report success unless all required verification and system builds succeed.

**Why this priority**: A pull request has already merged after its verification run failed before
creating jobs, demonstrating that the current pull-request rule is insufficient.

**Independent Test**: Inspect the workflow graph and live default-branch ruleset, then confirm the
aggregate gate depends on every required job and is configured as a required status check.

**Acceptance Scenarios**:

1. **Given** a pull request whose required evaluation or build fails, **When** GitHub evaluates the
   aggregate gate, **Then** the gate fails and the pull request cannot merge without an explicit
   authorized bypass.
2. **Given** every required evaluation and build succeeds, **When** the aggregate gate runs,
   **Then** it reports success under a stable name.

### User Story 2 - Minimize CI Credential and Supply-Chain Risk (Priority: P1)

As the repository operator, I need pull-request builds to consume public caches without receiving
cache-publishing credentials, and I need workflows to use only approved immutable Actions.

**Why this priority**: Dependency-update pull requests evaluate rapidly changing upstream code;
write credentials and mutable workflow dependencies unnecessarily widen that trust boundary.

**Independent Test**: Validate the workflow event conditions and query the live repository Action
permissions to prove PR jobs lack cache write authorization and immutable approved Actions are
enforced.

**Acceptance Scenarios**:

1. **Given** a pull-request workflow, **When** Cachix is configured, **Then** it receives no cache
   authentication token and checkout persists no GitHub credential.
2. **Given** a trusted `main` push, **When** Cachix is configured, **Then** publishing remains
   available through the scoped repository secret.
3. **Given** a workflow edit referencing an unapproved or non-immutable Action, **When** GitHub
   validates it, **Then** repository policy rejects that use.

### User Story 3 - Make Automation Bounded and Reviewable (Priority: P2)

As the repository operator, I need automation to terminate predictably, avoid duplicate updates,
periodically prove cache independence, and show package-level changes on lock-update pull requests.

**Why this priority**: These controls reduce operational cost and make dependency reviews more
informative without altering host behavior.

**Independent Test**: Validate workflow syntax and inspect triggers, concurrency, timeouts,
scheduled cache-independent jobs, and the dependency-diff summary path.

**Acceptance Scenarios**:

1. **Given** a duplicate scheduled or manual update, **When** another updater is active, **Then**
   only one update execution for the shared branch remains active.
2. **Given** a stuck evaluation or build, **When** its declared time budget expires, **Then** GitHub
   terminates the job.
3. **Given** the monthly verification schedule, **When** it runs, **Then** important outputs build
   using only the official Nix cache.
4. **Given** an automated lock-update pull request, **When** its comparison job succeeds, **Then**
   the run summary contains the changed system package set.

### Edge Cases

- Fork pull requests have no repository secrets and must still evaluate using public caches.
- An absent Cachix token on a pull request must not make cache configuration fail.
- The aggregate gate must run even when an upstream required job fails or is cancelled.
- A scheduled cache-independent run must not unintentionally run the full ordinary push workflow
  twice.
- The first deployment of the required gate must not block the remote default branch before the
  workflow containing that gate has been pushed.

## Requirements _(mandatory)_

### Functional Requirements

- **FR-001**: CI MUST expose one stable aggregate status that succeeds only when every required
  evaluation and build job succeeds.
- **FR-002**: The default-branch ruleset MUST require the stable aggregate status before merge.
- **FR-003**: Pull-request jobs MUST configure public cache consumption without cache write
  credentials or persisted checkout credentials.
- **FR-004**: Trusted default-branch pushes MUST retain cache publishing capability.
- **FR-005**: Every workflow job MUST declare a finite timeout appropriate to its expected cost.
- **FR-006**: The lock updater MUST prevent overlapping executions against its shared update branch.
- **FR-007**: Cache-independent output builds MUST run on a periodic schedule and remain manually
  invokable.
- **FR-008**: Automated flake update pull requests MUST produce a package-impact summary suitable
  for review.
- **FR-009**: Repository policy MUST require full commit SHA references and restrict Actions to
  GitHub-owned Actions plus the checked-in Determinate Systems, Cachix, and Gitleaks Actions.
- **FR-010**: Repository-native dependency security updates and static analysis for supported
  repository languages MUST be enabled.
- **FR-011**: GitHub workflow linting MUST be provided by the pinned Nix environment, run through
  the flake check used by CI, and run from the existing pre-commit hook.

### Invariants

- **INV-001**: All current flake checks, both host builds, and both VM test targets remain required
  verification work.
- **INV-002**: CI does not deploy or activate a host.
- **INV-003**: `systemStateVersion` and `homeStateVersion` remain unchanged.
- **INV-004**: Workflow permissions remain least-privilege and cache-independent jobs trust only
  the official Nix cache.

### Security and State

- **SEC-001**: Cache write authorization is limited to trusted default-branch push jobs; Actions
  are immutable and constrained to an explicit publisher allowlist.
- **STATE-001**: No host state, user state, state version, or migration is affected. Workflow and
  repository-setting rollback consists of reverting the commit and restoring the prior settings.

## Success Criteria _(mandatory)_

### Measurable Outcomes

- **SC-001**: One required aggregate check covers all five existing mandatory evaluation/build jobs
  with zero false-success paths.
- **SC-002**: Zero pull-request Cachix steps receive `CACHIX_AUTH_TOKEN`, and zero read-only checkout
  steps persist GitHub credentials.
- **SC-003**: Every declared job has a timeout, both workflows have concurrency control where
  overlap is possible, and cache-independent builds run at least monthly.
- **SC-004**: GitHub reports SHA pinning required, only the four approved third-party Action repositories allowed,
  Dependabot security updates enabled, secret scanning protections retained, and default CodeQL
  analysis configured for every supported detected language.
- **SC-005**: Repository governance validation passes and current-system memory accurately reflects
  the delivered CI and security model.
- **SC-006**: A malformed checked-in GitHub workflow fails both the declarative flake check and the
  repository pre-commit path without relying on a globally installed linter.

## Current-System Impact _(mandatory)_

- **Claims to update**: `Configuration, Caching, and Trust`; `Maintenance and Verification`;
  `Known Limitations and Planned Hardening` only if a new operational limitation is proven.
- **Limitations resolved or introduced**: Introduces the deployment-order constraint that the new
  aggregate check can become required only after its workflow exists on GitHub; no persistent
  system limitation is introduced.

## Assumptions

- Current checked-in Action publishers define the minimum allowlist.
- GitHub-hosted Actions and security features remain available for this public repository.
- Package-impact reporting may appear in the workflow run summary rather than mutating the pull
  request body, avoiding additional write permissions.
- The operator will push the resulting commit before the new aggregate status is made mandatory.
