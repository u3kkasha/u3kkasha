{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  makeWrapper,
  libsecret,
}:

let
  # Map Nix system strings to Antigravity download naming conventions
  platform =
    if stdenv.hostPlatform.isDarwin && stdenv.hostPlatform.isAarch64 then
      "darwin-arm64"
    else if stdenv.hostPlatform.isDarwin && stdenv.hostPlatform.isx86_64 then
      "darwin-amd64"
    else if stdenv.hostPlatform.isLinux && stdenv.hostPlatform.isAarch64 then
      "linux-arm64"
    else if stdenv.hostPlatform.isLinux && stdenv.hostPlatform.isx86_64 then
      "linux-amd64"
    else
      throw "Unsupported system: ${stdenv.hostPlatform.system}";

  # Version and platform-specific data retrieved from Google's manifests
  version = "1.0.1";

  sources = {
    "linux-amd64" = {
      url = "https://storage.googleapis.com/antigravity-public/antigravity-cli/1.0.1-5826024320139264/linux-x64/cli_linux_x64.tar.gz";
      hash = "sha512-vhF0oWXQa/Qf+3yxMAABRncfOEhrAFpopDxeYJH6gDIbOovNXTJeGJgftkiHC1lf9WMQgC1/kbsO2OdDJmhFOg==";
    };
    "linux-arm64" = {
      url = "https://storage.googleapis.com/antigravity-public/antigravity-cli/1.0.1-5826024320139264/linux-arm/cli_linux_arm64.tar.gz";
      hash = "sha512-pVxabP+Xlpl9EEtxMPw7K59PAc9hvmBrbNGSnknSIfLaMmWRUuE720cH/X0cUB0q1y4RwImn6niHzNHGW+sGcg==";
    };
    "darwin-arm64" = {
      url = "https://storage.googleapis.com/antigravity-public/antigravity-cli/1.0.1-5826024320139264/darwin-arm/cli_mac_arm64.tar.gz";
      hash = "sha512-bgvIqJlmgNBvtwz25S07jA2ga87ulxBsPXZybq7oyU7AOFeY68hf4AGAiMlP483SP7YfvTnsIHq5WJgMmF0O8A==";
    };
    "darwin-amd64" = {
      url = "https://storage.googleapis.com/antigravity-public/antigravity-cli/1.0.1-5826024320139264/darwin-x64/cli_mac_x64.tar.gz";
      hash = "sha512-14L4wyJYIQlEBQeQjDoRJCDmH+3FZ+2ATyDyOcLzNkEFMmwIzK2f5ubuqWHB8PHkLrfQaAd9Dc06820XSISbmw==";
    };
  };

  source = sources.${platform} or (throw "No source information for platform ${platform}");
in
stdenv.mkDerivation rec {
  pname = "antigravity-cli";
  inherit version;

  src = fetchurl {
    inherit (source) url hash;
  };

  nativeBuildInputs = [ makeWrapper ] ++ lib.optionals stdenv.isLinux [ autoPatchelfHook ];
  buildInputs = lib.optionals stdenv.isLinux [ libsecret ];

  dontBuild = true;
  dontConfigure = true;

  unpackPhase = ''
    tar -xzf $src
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp antigravity $out/bin/agy

    runHook postInstall
  '';

  meta = with lib; {
    description = "Google's Go-based terminal user interface (TUI) agent client";
    homepage = "https://antigravity.google";
    license = licenses.unfree;
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
      "x86_64-darwin"
      "aarch64-darwin"
    ];
    mainProgram = "agy";
  };
}
