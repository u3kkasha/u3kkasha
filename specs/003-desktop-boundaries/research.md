# Research: Desktop Boundaries

## Decision: Host-supplied Niri output fragment

**Rationale**: Home Manager should retain one owner of `niri/config.kdl`, while the host supplies
only its physical output text through an internal option.

**Alternatives considered**: A second `xdg.configFile` declaration risks merge conflicts; a
separate runtime include adds file topology for one stanza.

## Decision: Gate the complete pointer cursor attribute set

**Rationale**: Conditionalizing the full configuration removes both generated settings and the
cursor package dependency when GUI support is false.

**Alternatives considered**: Setting only `enable = false` could retain package evaluation.
