# Feature Specification: Clean Graphical Login

**Feature Branch**: `015-regreet-login`
**Created**: 2026-10-02
**Status**: Draft

## User Scenarios & Testing

### User Story 1 - Clean boot handoff (Priority: P1)

As a user, I want the login screen to remain readable during boot so that service
status messages do not appear in the username area.

**Acceptance Scenarios**

1. **Given** the graphical host boots, **When** the login screen appears, **Then**
   systemd and udev status messages are not rendered over the login interface.
2. **Given** a boot service fails, **When** the user investigates the failure,
   **Then** the failure remains available in the boot journal.

### User Story 2 - Graphical greetd login (Priority: P1)

As a user, I want a graphical greetd login screen that starts the configured Niri
session after successful authentication.

**Acceptance Scenarios**

1. **Given** greetd starts on the graphical host, **When** the login screen loads,
   **Then** ReGreet is displayed inside a Wayland greeter compositor.
2. **Given** valid credentials are submitted, **When** authentication succeeds,
   **Then** the existing Niri session starts.
3. **Given** the greeter exits or restarts, **When** greetd recovers the session,
   **Then** the login service remains enabled and usable.

## Functional Requirements

- **FR-001**: The system MUST prevent routine kernel, udev, and systemd boot status
  output from overwriting the graphical login interface.
- **FR-002**: Boot diagnostics MUST remain available through the system journal.
- **FR-003**: The graphical host MUST use ReGreet as the greetd frontend.
- **FR-004**: ReGreet MUST run under a Wayland compositor suitable for a greeter
  session.
- **FR-005**: Successful login MUST launch the existing Niri session command.
- **FR-006**: The WSL host MUST remain unaffected because it does not enable the
  graphical desktop module.

## Assumptions

- Cage is the minimal dedicated Wayland compositor for the ReGreet session.
- ReGreet's NixOS module supplies its package and required runtime integration.
- The configured `greeter` account remains the greetd account.

## Success Criteria

- **SC-001**: A graphical-host boot presents a clean login interface with no routine
  `[ OK ]` status lines in its input or window area.
- **SC-002**: The graphical host configuration evaluates and builds successfully.
- **SC-003**: The existing VM display-manager readiness check continues to pass.
- **SC-004**: Boot service failures remain discoverable with `journalctl -b`.

## Scope

This feature changes boot-console verbosity and the graphical host's greetd frontend.
It does not change user authentication, the Niri desktop session, or the WSL host.
