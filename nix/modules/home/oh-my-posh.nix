{ config, pkgs, theme, ... }:

{
  programs.oh-my-posh = {
    enable = true;
    useTheme = theme.posh;
    enableBashIntegration = true;
    enableNushellIntegration = true;
  };
}
