{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  makeWrapper,
  icu,
  openssl,
  zlib,
}:

stdenv.mkDerivation rec {
  pname = "aspire-cli";
  version = "13.3.3-preview.1.26264.13";

  src = fetchurl {
    url = "https://ci.dot.net/public/aspire/${version}/aspire-cli-linux-x64-13.3.3.tar.gz";
    sha256 = "sha256-qUAcCiyRSWQRM34HvJnDUtkjfhHr+FW1tjmwI/jyvJI=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
  ];

  buildInputs = [
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
        lib.makeLibraryPath [
          icu
          openssl
        ]
      }
  '';
}
