{
  pkgs,
  lib,
  config,
  inputs,
  ...
}:

let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.internal.utils;
  antigravityCli = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.antigravity-cli;
in
{
  options.internal.utils = {
    enable = mkEnableOption "Common CLI utilities configuration";
  };

  config = mkIf cfg.enable {
    programs.antigravity-cli = {
      enable = true;
      enableMcpIntegration = true;
      package = antigravityCli;
    };

    programs.bat = {
      enable = true;
    };

    programs.fzf = {
      enable = true;
      enableBashIntegration = true;
      enableNushellIntegration = false;
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

    programs.bottom = {
      enable = true;
    };

    programs.fastfetch = {
      enable = true;
    };

    programs.uv = {
      enable = true;
    };

    home.packages =
      with pkgs;
      [
        nvd
        ripgrep
        fd
        file
        jq
        nodejs_22
        mdr
        dotnet-sdk_10
        dust
        duckdb
        lazydocker
        ctop
      ]
      ++ lib.optionals config.internal.gui.enable [
        wl-clipboard
        firefox
      ];
  };
}
