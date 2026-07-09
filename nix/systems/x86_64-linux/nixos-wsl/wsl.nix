{
  lib,
  config,
  ...
}:

let
  inherit (lib.internal) username;
  cfg = config.internal.wsl;
in
{
  options.internal.wsl = {
    enable = lib.mkEnableOption "WSL specific configuration";
  };

  config = lib.mkIf cfg.enable {
    wsl.enable = true;
    wsl.defaultUser = username;
    wsl.interop.includePath = true;
    wsl.wslConf.interop.appendWindowsPath = true;
  };
}
