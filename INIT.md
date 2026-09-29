# Initial Setup

Run the following command to activate the WSL host directly from the GitHub flake:

```bash
sudo nixos-rebuild switch --flake github:u3kkasha/u3kkasha#nixos-wsl
```

For the bare-metal host, use `#nixos` instead of `#nixos-wsl`.
