{ pkgs, inputs, ... }:

let
  aspire-cli = inputs.self.packages.${pkgs.stdenv.hostPlatform.system}.aspire-cli;
in
{
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

  home.packages = with pkgs; [
    nvd
    ripgrep
    fd
    file
    jq
    wl-clipboard
    nodejs_22
    gemini-cli
    mdr
    dotnet-sdk_10
    nh
    aspire-cli
    doppler
    inputs.flox.packages.${pkgs.system}.default
  ];
}
