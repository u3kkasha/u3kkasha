{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:

{
  # Normalize the pinned theme before Lazygit loads immutable store files.
  catppuccin.sources.lazygit =
    let
      upstream = (import inputs.catppuccin { inherit pkgs; }).packages.lazygit;
    in
    pkgs.runCommand "catppuccin-lazygit-current-schema" { nativeBuildInputs = [ pkgs.yq-go ]; } ''
      cp -r ${upstream} "$out"
      chmod -R u+w "$out"
      for theme in "$out"/*/*.yml; do
        yq -i 'with(select(.gui.authorColors != null); .gui.theme.authorColors = .gui.authorColors | del(.gui.authorColors))' "$theme"
      done
    '';

  home.shellAliases = {
    lg = "lazygit";
  };

  programs.git = {
    enable = true;
    settings = {
      init.defaultBranch = "main";
      push.autoSetupRemote = true;
      pull.rebase = true;
      credential.helper = lib.mkIf config.internal.wsl.enable "/mnt/c/Program\\ Files/Git/mingw64/bin/git-credential-manager.exe";
      "credential \"https://dev.azure.com\"".useHttpPath = true;
    };
  };

  programs.difftastic = {
    enable = true;
    # git.enable is intentionally false — git diff uses the default.
    # difftastic is configured as lazygit's pager instead.
    git.enable = false;
    options = {
      background = "dark";
      display = "side-by-side";
    };
  };

  programs.gh = {
    enable = true;
    settings.git_protocol = "ssh";
    gitCredentialHelper.enable = true;
  };

  programs.lazygit = {
    enable = true;
    settings = {
      gui = {
        nerdFontsVersion = "3";
        parseEmoji = true;
        sidePanelWidth = 0.3333;
        mainPanelSplitMode = "horizontal";
      };
      git = {
        diffRenderers = [
          {
            # difftastic is the default lazygit pager (press | to cycle).
            type = "extDiff";
            command = "difft --color=always --background=dark --display=side-by-side";
          }
        ];
      };
    };
  };
}
