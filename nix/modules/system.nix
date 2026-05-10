{ pkgs, ... }:

      sha256 = "1l2df2h4psy42j9pyg8fhanxfahs25vn0gvpa0n7binz18z3szpp";
    };
    nativeBuildInputs = [ pkgs.autoPatchelfHook pkgs.makeWrapper ];
    buildInputs = with pkgs; [ stdenv.cc.cc.lib zlib icu openssl ];
    sourceRoot = ".";
    installPhase = ''
      mkdir -p $out/bin
      cp aspire $out/bin/
      wrapProgram $out/bin/aspire \
        --prefix LD_LIBRARY_PATH : ${pkgs.lib.makeLibraryPath [ pkgs.icu pkgs.openssl ]}
    '';
  };
in
{
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  system.stateVersion = "25.11";

  environment.systemPackages = with pkgs; [
    gemini-cli
    helix
    uv
    nushell
    mdr
    dotnet-sdk_10
  ];

  environment.shells = with pkgs; [ nushell ];

  users.users.nixos = {
    isNormalUser = true;
    shell = pkgs.nushell;
    extraGroups = [ "podman" ];
  };

  programs.nix-ld.enable = true;
  nixpkgs.config.allowUnfree = true;
}
