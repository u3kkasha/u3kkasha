# Task Completion

## Verification Checklist

1. **Formatting**: Run `nix fmt` to ensure code style compliance.
2. **Integrity**: Run `nix flake check` to verify flake syntax and basic sanity.
3. **Application**:
   - For system changes: `nh os switch .`
   - For user changes: `nh home switch .`
4. **Validation**: Manually verify the intended behavior (e.g., check that a new tool is in the PATH or a config change is reflected).

## Finality

A task is considered complete when:
- The change is implemented according to the request.
- All verification steps pass.
- No regressions are introduced.
