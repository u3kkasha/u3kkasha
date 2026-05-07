{ config, pkgs, ... }:

{
  programs.carapace = {
    enable = true;
    enableBashIntegration = true;
  };
}
