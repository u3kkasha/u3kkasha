# Research: Repository-Local Git Identity

## Decision: Declare no global identity

**Rationale**: The operator configures identity per repository. An absent global identity makes
misconfigured repositories fail visibly instead of silently using the wrong attribution.

**Alternatives considered**: Applying the shared values globally and retaining unused declarations
were both rejected because they conflict with the chosen ownership policy.
