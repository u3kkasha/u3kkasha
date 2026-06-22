{
  lib,
  config,
  pkgs,
  inputs,
  ...
}:

let
  inherit (lib)
    mkEnableOption
    mkIf
    mkOption
    types
    ;
  cfg = config.internal.git;
in
{
  options.internal.git = {
    enable = mkEnableOption "Git and related tools configuration";
    userName = mkOption {
      type = types.str;
      default = lib.internal.name;
      description = "The name to use for git commits";
    };
    userEmail = mkOption {
      type = types.str;
      default = lib.internal.email;
      description = "The email to use for git commits";
    };
  };

  config = mkIf cfg.enable {
    home.shellAliases = {
      lg = "lazygit";
    };

    programs.git = {
      enable = true;
      settings = {
        user = {
          name = cfg.userName;
          email = cfg.userEmail;
        };
        init.defaultBranch = "main";
        push.autoSetupRemote = true;
        pull.rebase = true;
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

    # hunk is a standalone diff viewer; no git/lazygit integration.
    home.packages = [
      inputs.hunk.packages.${pkgs.stdenv.hostPlatform.system}.hunk
    ];

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
  };
}
