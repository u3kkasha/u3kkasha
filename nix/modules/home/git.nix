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

  programs.difftastic = {
    enable = true;
    git.enable = true;
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
        showIcons = true;
        sidePanelWidth = 0.3333;
        mainPanelSplitMode = "horizontal";
      };
      git = {
        pagers = [
          {
            externalDiffCommand = "difft --color=always --background=dark --display=side-by-side";
          }
        ];
      };
    };
  };
}
