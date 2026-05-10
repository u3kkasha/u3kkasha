{ pkgs, theme, ... }:

{
  programs.zellij = {
    enable = true;
    settings = {
      theme = theme.zellij;
      default_layout = "compact";
      pane_frames = false;
      default_shell = "${pkgs.nushell}/bin/nu";
    };
  };
}
