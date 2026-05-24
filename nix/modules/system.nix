{
  pkgs,
  username,
  systemStateVersion,
  ...
}:

{
  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    auto-optimise-store = true;
    trusted-users = [
      "root"
      "@wheel"
      username
    ];
  };

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  system.stateVersion = systemStateVersion;

  environment.systemPackages = with pkgs; [
    nushell
  ];

  environment.shells = with pkgs; [ nushell ];

  users.users.${username} = {
    isNormalUser = true;
    shell = pkgs.nushell;
    extraGroups = [
      "wheel"
      "podman"
    ];
  };

  programs.nix-ld.enable = true;
  nixpkgs.config.allowUnfree = true;
}
