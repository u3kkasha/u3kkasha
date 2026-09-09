# Feature Specification: Full Headroom Integration

**Feature Directory**: `008-headroom-mcp`

**Created**: 2026-09-08

**Status**: Draft

**Input**: "Add Headroom to Codex and Antigravity CLI with everything Headroom provides."

Before completing this specification, read `.specify/memory/constitution.md` and
`.specify/memory/current-system.md`. Describe desired behavior, not implementation.

## Intent and Scope _(mandatory)_

### Problem

The configured agents cannot currently use Headroom. A minimal MCP-only build would omit
Headroom's model proxy, ML compression, memory, image, relevance, reporting, evaluation, voice,
HTML, spreadsheet, and observability capabilities, contrary to the operator's requested scope.
Imperative installation would also bypass the configuration's reproducibility and shared-client
integration guarantees.

### Desired Outcome

The configured user receives Headroom's complete officially bundled capability set, including its
local MCP tools and an opt-in provider proxy path for supported clients. Headroom is installed
reproducibly with its runtime dependencies and required model assets pinned. It is registered once
in the shared MCP registry and projected into every already-enabled MCP client, including Codex,
Antigravity CLI, and OpenCode. Normal agent commands remain direct unless the user explicitly
chooses the Headroom proxy launcher.

### Out of Scope

- Automatically routing every normal agent invocation through Headroom.
- Transparent provider-proxy routing for Antigravity CLI while upstream compatibility remains
  incomplete; Antigravity receives the complete MCP integration instead.
- Enabling optional provider credentials, external memory services, or remote model inference by
  default.
- Features not included in Headroom's official complete installation bundle unless required by an
  enabled bundled capability.

## Affected Targets _(mandatory)_

| Target or layer                  | Affected? | Expected observable change                                                              |
| -------------------------------- | --------- | --------------------------------------------------------------------------------------- |
| `nixos` host                     | Yes       | Its configured user receives full Headroom tooling and MCP integration.                 |
| `nixos-wsl` host                 | Yes       | Its configured user receives full Headroom tooling and MCP integration.                 |
| Shared NixOS modules             | No        | N/A                                                                                     |
| Shared Home Manager modules      | Yes       | Headroom, its MCP entry, assets, and opt-in launch behavior are owned declaratively.    |
| Developer shell or agent tooling | Yes       | All enabled MCP clients expose Headroom; supported clients can opt into proxy routing.  |
| CI, caching, or verification     | Yes       | Package, assets, generated configuration, proxy, protocol, and both hosts are verified. |

## User Scenarios & Testing _(mandatory)_

Treat the operator, configured user, and downstream project as the relevant users. Each story
represents an independently verifiable configuration outcome.

### User Story 1 - Use Complete Headroom Tooling (Priority: P1)

The configured user can run Headroom's complete bundled feature set without installing additional
Python packages, native libraries, helper binaries, or default model assets at runtime.

**Why this priority**: Complete local capability is the explicitly requested outcome and is the
foundation for every client integration.

**Independent Test**: Build the isolated Headroom package and exercise representative imports and
smoke operations for every bundled capability group with network access disabled.

**Acceptance Scenarios**:

1. **Given** the locked repository inputs, **When** Headroom is built, **Then** its complete bundled
   dependency closure and default assets are produced as immutable artifacts.
2. **Given** the built package with network access disabled, **When** representative bundled
   capabilities initialize, **Then** they use packaged dependencies and assets rather than a
   runtime installer or download.

### User Story 2 - Use Headroom From Every MCP Agent (Priority: P1)

The configured user starts Codex, Antigravity CLI, or OpenCode and can access the same Headroom
compression, retrieval, and statistics tools in each client.

**Why this priority**: Codex and Antigravity access are the original requested integrations, and
the shared registry deliberately supplies the same capability to every enabled MCP client.

**Independent Test**: Evaluate both supported host configurations, inspect all generated client
projections, and complete MCP initialization, tool discovery, compression, and retrieval.

**Acceptance Scenarios**:

1. **Given** either supported host configuration, **When** its Home Manager configuration is
   evaluated, **Then** Headroom appears exactly once in the shared registry and every client
   projection.
2. **Given** an activated configuration, **When** a client starts Headroom, **Then** it can discover
   the three tools, compress suitable content, and retrieve the exact original.

### User Story 3 - Opt Into Transparent Codex Compression (Priority: P2)

The configured user can deliberately start a Codex session whose model traffic passes through a
local Headroom proxy, while ordinary Codex sessions remain unchanged.

**Why this priority**: Proxy mode unlocks automatic whole-request optimization but introduces a
larger authentication, state, and local-network boundary than MCP tools.

**Independent Test**: Start the opt-in proxy path, confirm loopback health and Codex provider
routing, then stop it and verify the normal Codex configuration and command still work directly.

**Acceptance Scenarios**:

1. **Given** existing Codex authentication, **When** the user selects the Headroom launcher,
   **Then** a loopback-only proxy starts and Codex routes through it without persisting or logging
   credentials.
2. **Given** the user does not select the Headroom launcher, **When** Codex starts normally,
   **Then** its provider route remains unchanged.
3. **Given** the Headroom session ends or startup fails, **When** cleanup completes, **Then** no
   stale proxy routing prevents a subsequent normal Codex session.

### Edge Cases

- A missing or incompatible complete-feature dependency fails evaluation or build rather than
  silently downgrading the package.
- A missing packaged model asset fails its feature-specific check rather than downloading an
  unpinned replacement.
- If no proxy is running, MCP-local compression and retrieval remain usable.
- Antigravity provider traffic remains direct because its current Cloud Code protocol is not a
  supported transparent proxy target.
- Existing user-owned Codex settings outside explicitly managed Headroom and MCP sections remain
  intact.

## Requirements _(mandatory)_

### Functional Requirements

- **FR-001**: The configuration MUST provide a reproducibly pinned Headroom executable with every
  capability group in its official complete installation bundle on both supported hosts.
- **FR-002**: Default model and tokenizer assets required by enabled local capabilities MUST be
  immutable, versioned inputs available without runtime download.
- **FR-003**: The shared MCP registry MUST contain exactly one Headroom stdio server definition.
- **FR-004**: Every enabled MCP-integrated client MUST receive the shared Headroom definition,
  including Codex, Antigravity CLI, and OpenCode on both supported hosts.
- **FR-005**: The MCP server MUST initialize, list compression, retrieval, and statistics tools,
  compress supported content, and retrieve the exact original without a running proxy.
- **FR-006**: Agent and Headroom startup MUST NOT invoke a runtime package or dependency resolver.
- **FR-007**: The configuration MUST provide an explicit, opt-in Codex proxy launch path while
  leaving the normal Codex command and provider selection unchanged.
- **FR-008**: The opt-in proxy MUST bind only to loopback and clean up routing/lifecycle state when
  the launched Codex session exits or startup fails.
- **FR-009**: Automated checks MUST verify the complete package, pinned assets, registry membership,
  every client projection, MCP round-trip behavior, and both host compositions. Proxy health and
  cleanup MUST be smoke-tested on the live host rather than under software-emulated QEMU.

### Invariants

- **INV-001**: Existing MCP servers and generated client configurations MUST remain available.
- **INV-002**: The user-owned writable Codex configuration merge behavior MUST preserve unrelated
  user settings.
- **INV-003**: Normal Codex and Antigravity CLI invocations MUST retain their existing provider and
  authentication behavior.
- **INV-004**: State compatibility versions, daemon trust, unfree policy, and host boundaries MUST
  remain unchanged unless a required complete-feature dependency forces an explicitly documented
  policy decision.

### Security and State

- **SEC-001**: Provider credentials handled by an opt-in proxy MUST remain process-scoped, must not
  be written to declarative configuration or logs, and must not be exported globally.
- **SEC-002**: The proxy MUST be disabled by default and bind to `127.0.0.1` only when explicitly
  launched.
- **SEC-003**: External telemetry and remote model inference MUST remain disabled by default;
  local observability capabilities may remain available.
- **STATE-001**: Headroom's caches, memory, statistics, and proxy state MUST be user-scoped and
  disposable; no compatibility-version change or automatic migration is permitted.
- **STATE-002**: Rollback MUST remove client registrations and launch paths without requiring the
  deletion of user data; optional stale Headroom state may be removed manually.

## Success Criteria _(mandatory)_

### Measurable Outcomes

- **SC-001**: Representative checks for 100% of Headroom's officially bundled capability groups
  pass from the packaged environment with runtime network access disabled.
- **SC-002**: All 2 supported host configurations expose one Headroom entry through the shared
  registry and all 3 enabled MCP-integrated clients.
- **SC-003**: 100% of local Headroom commands and default assets resolve to immutable package paths
  and avoid runtime resolvers or downloads.
- **SC-004**: MCP initialization, discovery of exactly the required tool set, a compression, and an
  exact retrieval round trip pass on both runtime integration targets.
- **SC-005**: A live-host opt-in Codex proxy reports healthy on loopback, cleans up after Codex
  exits, and leaves the ordinary Codex configuration byte-identical.
- **SC-006**: Unit, generated-configuration, formatting, both affected host build, and both affected
  runtime integration checks complete successfully.

## Current-System Impact _(mandatory)_

- **Claims to update**: Home Manager and Agent Tooling must identify the full Headroom package,
  pinned local assets, shared MCP tools, and opt-in Codex proxy path; configuration/security text
  must record the loopback and credential boundary; verification must cover the new package and
  runtime behavior.
- **Limitations resolved or introduced**: Introduce the explicit limitation that transparent
  Headroom provider proxying is not configured for Antigravity CLI; its complete MCP integration
  remains supported.

## Assumptions

- "Everything Headroom provides" means Headroom's official complete installation bundle plus its
  supported MCP and Codex proxy surfaces, not every third-party provider adapter or external
  database service that can be installed separately.
- Proxy routing is opt-in per Codex session rather than an always-running or globally selected
  provider.
- Default local assets can be pinned and packaged within acceptable build and closure costs.
