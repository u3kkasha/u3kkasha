{
  lib,
  config,
  namespace,
  ...
}:

let
  inherit (lib.${namespace}) username;
  cfg = config.${namespace}.wsl;
in
{
  options.${namespace}.wsl = {
    enable = lib.mkEnableOption "WSL specific configuration";
  };

  config = lib.mkIf cfg.enable {
    wsl.enable = true;
    wsl.defaultUser = username;
    wsl.interop.includePath = false;
    wsl.wslConf.interop.appendWindowsPath = false;
  };
}
