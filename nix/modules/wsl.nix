{ username, ... }:

{
  wsl.enable = true;
  wsl.defaultUser = username;
  wsl.interop.includePath = false;
  wsl.wslConf.interop.appendWindowsPath = false;
}
