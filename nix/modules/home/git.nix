{
  config,
  lib,
  ...
}:

{
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
        theme = {
          optionsTextColor = [ "#cba6f7" ]; # Mauve (Purple) for better readability
        };
      };
      git = {
        pagers = [
          {
            # difftastic is the default lazygit pager (press | to cycle).
            externalDiffCommand = "difft --color=always --background=dark --display=side-by-side";
          }
        ];
      };
    };
  };
}
