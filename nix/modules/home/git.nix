_:

{
  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "Fida Waseque Choudhury";
        email = "fida.waseque@gmail.com";
      };
      init.defaultBranch = "main";
      push.autoSetupRemote = true;
      pull.rebase = true;
    };
  };

  programs.delta = {
    enable = true;
    enableGitIntegration = false;
  };

  programs.difftastic = {
    enable = true;
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
        theme = {
          activeBorderColor = [
            "#89b4fa"
            "bold"
          ];
          inactiveBorderColor = [ "#a6adc8" ];
          optionsTextColor = [ "#89b4fa" ];
          selectedLineBgColor = [ "#313244" ];
          cherryPickedCommitBgColor = [ "#45475a" ];
          cherryPickedCommitFgColor = [ "#89b4fa" ];
          unstagedChangesColor = [ "#f38ba8" ];
          defaultFgColor = [ "#cdd6f4" ];
          searchingActiveBorderColor = [ "#f9e2af" ];
        };
        showIcons = true;
        sidePanelWidth = 0.3333;
        mainPanelSplitMode = "vertical";
      };
      git = {
        pagers = [
          {
            colorArg = "always";
            pager = "delta --dark --paging=always";
            useExternalDiff = true; # This enables the use of externalDiffCommand
          }
        ];
        externalDiffCommand = "difft --color=always --background=dark --display=side-by-side";
      };
    };
  };
}
