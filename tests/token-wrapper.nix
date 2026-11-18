{ pkgs }:
pkgs.runCommand "token-wrapper-tests"
  {
    nativeBuildInputs = [
      pkgs.bash
      pkgs.nushell
      pkgs.python3
    ];
    BASH = "${pkgs.bash}/bin/bash";
    NU = "${pkgs.nushell}/bin/nu";
    BASH_WRAPPER = "${../modules/home/nix-token-wrapper.bash}";
    NU_WRAPPER = "${../modules/home/nix-token-wrapper.nu}";
  }
  ''
    python3 ${./token-wrapper-runner.py}
    touch "$out"
  ''
