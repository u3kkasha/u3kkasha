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

      # devenv shell integration
      eval "$(devenv hook bash)"

      # Export GitHub token from gh if available
      if command -v gh >/dev/null 2>&1; then
        export GITHUB_TOKEN=$(gh auth token 2>/dev/null)
      fi
    '';
  };
}
