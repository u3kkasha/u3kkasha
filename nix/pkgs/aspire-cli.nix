{ pkgs }:

pkgs.stdenv.mkDerivation {
  pname = "aspire-cli";
  version = "13.3.0";
  src = pkgs.fetchurl {
    url = "https://aka.ms/dotnet/9/aspire/ga/daily/aspire-cli-linux-x64.tar.gz";
    sha256 = "1l2df2h4psy42j9pyg8fhanxfahs25vn0gvpa0n7binz18z3szpp";
  };
  nativeBuildInputs = [
    pkgs.autoPatchelfHook
    pkgs.makeWrapper
  ];
  buildInputs = with pkgs; [
    stdenv.cc.cc.lib
    zlib
    icu
    openssl
  ];
  sourceRoot = ".";
  installPhase = ''
    mkdir -p $out/bin
    cp aspire $out/bin/
    wrapProgram $out/bin/aspire \
      --prefix LD_LIBRARY_PATH : ${
        pkgs.lib.makeLibraryPath [
          pkgs.icu
          pkgs.openssl
        ]
      }
  '';
}
