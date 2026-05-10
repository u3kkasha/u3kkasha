{
  programs.bash = {
    enable = true;
    enableCompletion = true;
    shellAliases = {
      cleanup = "nh clean all; nix-collect-garbage -d; sudo nix-collect-garbage -d";
    };
  };
}
