{
  programs.bash = {
    enable = true;
    enableCompletion = true;
    shellAliases = { };
    bashrcExtra = ''
      # Load Doppler secrets if logged in
      if [ -f ~/.doppler/config.yaml ]; then
        eval "$(doppler secrets download --no-tag --format docker)"
      fi
    '';
  };
}
