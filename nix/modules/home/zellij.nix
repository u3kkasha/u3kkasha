{ config, pkgs, theme, ... }:

{
  programs.zellij = {
    enable = true;
    settings = {
      theme = theme.zellij;
      default_layout = "compact";
      pane_frames = false;
    };
  };
}
