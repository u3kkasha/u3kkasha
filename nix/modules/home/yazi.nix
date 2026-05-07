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

  home.packages = with pkgs; [
    delta # Recommended for lazygit paging
  ];
}
