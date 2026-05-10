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

  home.packages = with pkgs; [
    nvd
    delta
    ripgrep
    fd
    file
    jq
    wl-clipboard
  ];
}
