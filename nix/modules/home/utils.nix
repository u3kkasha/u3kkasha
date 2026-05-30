{
  pkgs,
  lib,
  config,
  ...
}:

let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.internal.utils;
in
{
  options.internal.utils = {
    enable = mkEnableOption "Common CLI utilities configuration";
  };

  config = mkIf cfg.enable {
    programs.bat = {
      enable = true;
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

    home.packages =
      with pkgs;
      [
        nixd
        nvd
        ripgrep
        fd
        file
        jq
        nodejs_22
        gemini-cli
        mdr
        dotnet-sdk_10
        nh
        doppler
      ]
      ++ lib.optionals config.internal.gui.enable [
        wl-clipboard
        firefox
      ];
  };
}
