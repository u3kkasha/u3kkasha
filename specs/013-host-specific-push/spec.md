# Host-specific push verification

## User scenarios

### Scenario: Push from a supported host

As a maintainer, I want a push to build only the NixOS host I am using, so unrelated
host packages are not downloaded for local verification.

**Acceptance criteria**

- Given the local hostname is `nixos`, the pre-push hook builds `nixos-build`.
- Given the local hostname is `nixos-wsl`, the pre-push hook builds `nixos-wsl-build`.
- Common lightweight checks still run before a push.
- `NIXOS_HOST` can explicitly select either supported host.
- An unsupported host fails with a useful message instead of silently skipping the build.

## Assumptions

- Cross-host configuration and VM checks remain covered by CI.
- The workstation hostname matches the configured host name unless overridden.
