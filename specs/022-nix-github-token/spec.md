# Feature Specification: Pass GitHub CLI Credentials to Nix

**Feature Branch**: `022-nix-github-token`
**Created**: 2026-11-18
**Status**: Implemented
**Input**: User description: "Pass the existing GitHub CLI token to Nix at runtime."

## User Scenarios & Testing

### User Story 1 - Authenticated GitHub fetches (Priority: P1)

As a user running Nix commands in Bash or Nushell, I want Nix to use my existing GitHub CLI token so GitHub-hosted flake requests can avoid unauthenticated API limits.

**Why this priority**: This is the requested outcome and avoids maintaining a second credential.

**Independent Test**: Run a Nix command in either configured shell while `gh auth status` succeeds and confirm GitHub requests receive an access token; repeat without a token and confirm the command still runs normally.

**Acceptance Scenarios**:

1. **Given** GitHub CLI has an authenticated account, **When** the user runs `nix`, **Then** that invocation receives `access-tokens = github.com=<token>`.
2. **Given** GitHub CLI is unavailable or unauthenticated, **When** the user runs `nix`, **Then** Nix runs without the injected token.
3. **Given** the user has existing `NIX_CONFIG`, **When** the user runs `nix`, **Then** existing settings remain available to that invocation.

### Edge Cases

- Token lookup errors or returns an empty token; Nix should run with its normal configuration.
- The token must not be written into the Nix store, flake source, or generated persistent configuration.

## Requirements

### Functional Requirements

- **FR-001**: Bash and Nushell Nix invocations MUST query the existing GitHub CLI credential at runtime.
- **FR-002**: The token MUST be scoped to each Nix process through `NIX_CONFIG` and MUST NOT be exported globally.
- **FR-003**: Existing `NIX_CONFIG` settings MUST be preserved when adding the GitHub access token.
- **FR-004**: Nix commands MUST continue to run normally when GitHub CLI token lookup fails.

## Success Criteria

### Measurable Outcomes

- **SC-001**: Authenticated invocations in both configured shells receive the GitHub token without storing it in generated files.
- **SC-002**: Token lookup failure does not prevent a Nix command from being executed.

## Assumptions

- GitHub CLI is already installed and configured by Home Manager.
- Only commands launched from the managed Bash and Nushell shells are in scope.
- Supplying a GitHub API token can relieve API rate limits but does not accelerate builds or unrelated downloads.
