# Data Model: Bare-Metal Desktop Rebuild

No persistent data entities are introduced.

The relevant declarative values are:

- the `nixos` host desktop capability;
- the selected Niri and Noctalia package/module outputs;
- public cache URLs and trusted keys;
- the GUI capability flag separating bare-metal and WSL Home Manager composition;
- retained infrastructure capabilities (Docker, gaming, development, MCP, and WSL).
