{
  programs.bash = {
    enable = true;
    enableCompletion = true;
    shellAliases = {
      cleanup = "nix run .#clean";
    };
    bashrcExtra = ''
      # Load Doppler secrets if logged in
      if [ -f ~/.doppler/config.yaml ]; then
        eval "$(doppler secrets download --no-tag --format docker)"
      fi
    '';
  };
}
