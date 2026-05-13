{ pkgs, theme, ... }:

{
  programs.bat = {
    enable = true;
    config = {
      theme = theme.bat;
    };
  };

  programs.fzf = {
    enable = true;
    enableBashIntegration = true;
  };

  programs.zoxide = {
    enable = true;
    enableBashIntegration = true;
    enableNushellIntegration = true;
  };

  programs.eza = {
    enable = true;
    enableBashIntegration = false;
    enableNushellIntegration = false;
    git = true;
    icons = "auto";
  };

  programs.uv = {
    enable = true;
  };

  home.packages = with pkgs; [
    nvd
    ripgrep
    fd
    file
    jq
    wl-clipboard
    nodejs_22
  ];
}
