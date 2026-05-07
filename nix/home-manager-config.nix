{ config, pkgs, ... }:

{
  programs.helix = {
    enable = true;
    defaultEditor = true;
    extraPackages = with pkgs; [
      nil
      nixpkgs-fmt
      bash-language-server
      pyright
      vscode-langservers-extracted
      prettier
    ];
    settings = {
      theme = "catppuccin_mocha";
      editor = {
        true-color = true;
        line-number = "relative";
        cursorline = true;
        color-modes = true;
        cursor-shape = {
          insert = "bar";
          normal = "block";
          select = "underline";
        };
        indent-guides = {
          render = true;
          character = "┊";
        };
        lsp = {
          display-messages = true;
          display-inlay-hints = true;
        };
        soft-wrap = {
          enable = true;
        };
        statusline = {
          left = ["mode" "spinner" "file-name" "read-only-indicator" "file-modification-indicator"];
          right = ["diagnostics" "selections" "position" "file-encoding" "file-line-ending" "file-type"];
          mode.normal = "NORMAL";
          mode.insert = "INSERT";
          mode.select = "SELECT";
        };
      };
    };
    languages = {
      language = [
        {
          name = "json";
          auto-format = true;
          formatter = {
            command = "prettier";
            args = [
              "--parser"
              "json"
            ];
          };
        }
      ];
    };
  };

  programs.zellij = {
    enable = true;
    settings = {
      theme = "catppuccin-mocha";
      default_layout = "compact";
      pane_frames = false;
    };
  };

  programs.git = {
    enable = true;
  };

  programs.gh = {
    enable = true;
    settings.git_protocol = "ssh";
    gitCredentialHelper.enable = true;
  };

  home.stateVersion = "25.11";
}
