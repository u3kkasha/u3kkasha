{ config, pkgs, ... }:

{
  programs.television = {
    enable = true;
    enableBashIntegration = true;
    enableNushellIntegration = true;
  };
}
