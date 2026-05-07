{ config, pkgs, ... }:

{
  programs.yazi = {
    enable = true;
    enableBashIntegration = true;
    shellWrapperName = "y";
    settings = {
      manager = {
        show_hidden = true;
        sort_by = "mtime";
        sort_reverse = true;
      };
    };
    keymap = {
      manager.prepend_keymap = [
        {
          on = [ "G" ];
          run = "shell 'lazygit' --block";
          desc = "Open lazygit";
        }
        {
          on = [ "C-f" ];
          run = "filter";
          desc = "Filter files";
        }
        {
          on = [ "F" ];
          run = "shell 'fzf-search' --block";
          desc = "FZF search";
        }
      ];
    };
  };

  programs.lazygit = {
    enable = true;
    settings = {
      git = {
        pagers = [
          {
            colorArg = "always";
            pager = "delta --dark --paging=always";
          }
        ];
      };
    };
  };

  programs.zoxide = {
    enable = true;
    enableBashIntegration = true;
  };

  programs.bat = {
    enable = true;
    config = {
      theme = "TwoDark";
    };
  };

  programs.fzf = {
    enable = true;
    enableBashIntegration = true;
  };

  home.packages = with pkgs; [
    delta
    ripgrep
    fd
  ];
}
