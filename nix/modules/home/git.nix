{ config, pkgs, ... }:

{
  programs.git = {
    enable = true;
  };

  programs.gh = {
    enable = true;
    settings.git_protocol = "ssh";
    gitCredentialHelper.enable = true;
  };
}
