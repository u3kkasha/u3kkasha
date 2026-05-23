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
    substituters = [ "https://cache.flox.dev" ];
    trusted-public-keys = [ "flox-cache-public-1:7F4OyH7ZCnFhcze3fJdfyXYLQw/aV7GEed86nQ7IsOs=" ];
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
