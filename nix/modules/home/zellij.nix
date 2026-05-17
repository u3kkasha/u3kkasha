{ pkgs, ... }:

{
  programs.zellij = {
    enable = true;
    settings = {
      default_layout = "compact";
      pane_frames = false;
      default_shell = "${pkgs.nushell}/bin/nu";
    };
  };
}
