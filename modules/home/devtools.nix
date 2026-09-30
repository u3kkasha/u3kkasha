{
  pkgs,
  lib,
  config,
  inputs,
  ...
}:

let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.internal.devtools;
  skillsCli = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.skills;
in
{
  options.internal.devtools = {
    enable = mkEnableOption "Developer tools and language runtimes configuration";
  };

  config = mkIf cfg.enable {
    programs.uv.enable = true;

    home.packages = with pkgs; [
      nodejs_22
      mdr
      dotnet-sdk_10
      duckdb
      skillsCli
    ];
  };
}
