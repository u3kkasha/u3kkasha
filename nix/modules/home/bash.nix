{
  programs.bash = {
    enable = true;
    enableCompletion = true;
    shellAliases = {
      cleanup = "nh clean all; nix-collect-garbage -d; sudo nix-collect-garbage -d";
    };
    bashrcExtra = ''
      # Load Doppler secrets if logged in
      if [ -f ~/.doppler/config.yaml ]; then
        eval "$(doppler secrets download --no-tag --format docker)"
      fi
    '';
  };
}
