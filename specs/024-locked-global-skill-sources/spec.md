# Feature Specification: Lock Global Skill Sources

**Feature Branch**: `024-locked-global-skill-sources`

**Created**: 2026-11-18

**Status**: Approved

**Input**: User request: "can we do this for all skills, I already have a flake upater in the github actions CI, so how does all of this tie up together?"

## User Scenarios & Testing

### User Story 1 - Update global skills through the flake lock (Priority: P1)

As a system maintainer, I want every externally sourced global skill catalog tracked by the flake lock so scheduled dependency updates can propose skill updates alongside other system inputs.

**Why this priority**: The existing CI updater only updates locked flake inputs; moving skill sources into the lock makes the existing review and verification path cover them.

**Independent Test**: Evaluate both host configurations and confirm all global skill paths resolve from their locked inputs.

**Acceptance Scenarios**:

1. **Given** the scheduled lock updater runs, **When** an upstream skill repository has new commits, **Then** the lock update pull request includes updated revisions for those declared skill inputs.
2. **Given** the update pull request is opened, **When** normal CI runs, **Then** both supported host configurations are checked with the candidate skill sources before merge.
3. **Given** the update is merged, **When** the system is rebuilt, **Then** the newly locked skill catalogs are installed declaratively.

### Edge Cases

- Upstream changes may remove or relocate a skill path, causing host evaluation to fail and the update PR to expose the incompatibility.
- A skill source must remain reproducible between lock updates even though its flake declaration follows an upstream branch.
- The selected Nix skills already use a locked flake input and must remain configured as before.

## Requirements

### Functional Requirements

- **FR-001**: System MUST declare each externally sourced global skill catalog as a flake input.
- **FR-002**: System MUST consume those locked input sources from shared Home Manager configuration without separate untracked revision and hash declarations.
- **FR-003**: System MUST keep all existing global skills available through their current agent integrations.
- **FR-004**: System MUST allow the existing CI lock updater to refresh all declared skill inputs and open its normal update pull request.
- **FR-005**: System MUST preserve deterministic skill installation between lock updates.

## Success Criteria

### Measurable Outcomes

- **SC-001**: All globally configured external skill catalogs have entries in `flake.lock`.
- **SC-002**: Both host configurations evaluate successfully using their locked skill sources.
- **SC-003**: A normal CI lock update can include skill source revisions without changing the updater workflow.

## Assumptions

- "All skills" means all global skill sources in the current configuration: nix-skills, dotnet/skills, GoogleChrome/modern-web-guidance, and nuxt/ui.
- The existing weekly lock updater and pull-request CI remain the review, compatibility-check, and merge path.
- Upstream branches may advance, but installed content changes only when an updated lockfile is merged and the system is rebuilt.

## Current-System Impact

- Global skill source revisions become ordinary locked flake inputs; update the Home Manager, flake dependency, and maintenance workflow descriptions in `.specify/memory/current-system.md`.
