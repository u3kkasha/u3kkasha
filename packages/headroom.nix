{
  lib,
  stdenv,
  python3,
  rustPlatform,
  autoPatchelfHook,
  ast-grep,
  difftastic,
  fetchurl,
  headroom-models,
  headroom-src,
  scc,
}:

let
  python = python3.override {
    packageOverrides = final: prev: {
      tree-sitter-language-pack = prev.buildPythonPackage {
        pname = "tree-sitter-language-pack";
        version = "0.10.0";
        format = "wheel";
        src = fetchurl {
          url = "https://files.pythonhosted.org/packages/34/62/033b2a380a60bcb36462074240d4434883b198bdf24d4d0b21c5df60f0c4/tree_sitter_language_pack-0.10.0-cp310-abi3-manylinux2014_x86_64.whl";
          hash = "sha256-ATsThQO0Cw0kKUp2UtW7yZiv/lBv7eRfovfQLJtrGSw=";
        };
        nativeBuildInputs = [ autoPatchelfHook ];
        dependencies = with final; [
          tree-sitter
          tree-sitter-c-sharp
          tree-sitter-embedded-template
          tree-sitter-yaml
        ];
        pythonImportsCheck = [ "tree_sitter_language_pack" ];
      };

      sentence-transformers = prev.sentence-transformers.overridePythonAttrs (_old: rec {
        version = "5.7.0";
        src = prev.fetchPypi {
          pname = "sentence_transformers";
          inherit version;
          hash = "sha256-/YyPw15jI2Md/583YJaev3mA3Dz9oKsTVLxqd0zA5dg=";
        };
        doCheck = false;
      });

      datasets = prev.datasets.overridePythonAttrs (_old: rec {
        version = "5.0.1";
        src = prev.fetchPypi {
          inherit version;
          pname = "datasets";
          hash = "sha256-ziK7hR79dJTwiq0zuUCAN4RDT253dj0AZ5oNxF/PaGo=";
        };
      });

      pydantic-settings = prev.pydantic-settings.overridePythonAttrs (old: rec {
        version = "2.14.2";
        src = prev.fetchPypi {
          pname = "pydantic_settings";
          inherit version;
          hash = "sha256-wZ3WSxkJfx3oAYTwzHsCcqE65uFwy/JAo+J+OB7RSl8=";
        };
        dependencies = old.dependencies ++ [ final.typing-inspection ];
      });

      torch = prev.buildPythonPackage {
        pname = "torch";
        version = "2.12.1";
        format = "wheel";
        src = fetchurl {
          url = "https://download.pytorch.org/whl/cpu/torch-2.12.1%2Bcpu-cp314-cp314-manylinux_2_28_x86_64.whl";
          name = "torch-2.12.1+cpu-cp314-cp314-manylinux_2_28_x86_64.whl";
          hash = "sha256-YYEg15NgaIWV5hFiFH034dafw/LhPWBYSh62p0x0c1o=";
        };
        nativeBuildInputs = [ autoPatchelfHook ];
        buildInputs = [ stdenv.cc.cc.lib ];
        dependencies = with final; [
          filelock
          fsspec
          jinja2
          networkx
          setuptools
          sympy
          typing-extensions
        ];
        pythonRelaxDeps = [ "setuptools" ];
        pythonImportsCheck = [ "torch" ];
        meta.license = lib.licenses.bsd3;
      };
    };
  };
in
python.pkgs.buildPythonApplication {
  pname = "headroom-ai";
  version = "0.36.0";
  pyproject = true;

  src = headroom-src;

  cargoDeps = rustPlatform.importCargoLock {
    lockFile = "${headroom-src}/Cargo.lock";
  };

  nativeBuildInputs = [
    rustPlatform.cargoSetupHook
    rustPlatform.maturinBuildHook
  ];

  build-system = [
    rustPlatform.cargoSetupHook
    rustPlatform.maturinBuildHook
  ];

  dependencies = with python.pkgs; [
    anthropic
    click
    datasets
    fastapi
    fastembed
    h2
    httpx
    huggingface-hub
    jinja2
    magika
    mcp
    numpy
    onnxruntime
    openai
    openpyxl
    opentelemetry-api
    opentelemetry-exporter-otlp-proto-http
    opentelemetry-sdk
    orjson
    pillow
    pydantic
    pyyaml
    rapidocr
    rich
    scikit-learn
    sentence-transformers
    sentencepiece
    sqlite-vec
    tiktoken
    tomlkit
    torch
    trafilatura
    transformers
    tree-sitter
    tree-sitter-language-pack
    uvicorn
    watchdog
    websockets
    xlrd
    zstandard
  ];

  # PyPI's ast-grep-cli package only distributes the upstream binary. Nix
  # supplies that binary directly through the wrapped PATH above.
  pythonRemoveDeps = [ "ast-grep-cli" ];

  nativeCheckInputs = [ python.pkgs.pytestCheckHook ];
  doCheck = false;

  passthru = {
    inherit python headroom-models;
  };

  pythonImportsCheck = [
    "headroom"
    "headroom.cli.mcp"
    "headroom.proxy"
  ];

  postFixup = ''
    wrapProgram "$out/bin/headroom" \
      --prefix PATH : ${
        lib.makeBinPath [
          ast-grep
          difftastic
          scc
        ]
      } \
      --set-default HF_HOME ${headroom-models} \
      --set-default HF_HUB_CACHE ${headroom-models}/hub \
      --set-default HF_HUB_OFFLINE 1 \
      --set-default TRANSFORMERS_OFFLINE 1 \
      --set-default TIKTOKEN_CACHE_DIR ${headroom-models}/tiktoken \
      --set-default HEADROOM_SENTENCE_TRANSFORMER ${headroom-models.sentenceTransformer} \
      --set-default HEADROOM_UPDATE_CHECK off \
      --set-default DO_NOT_TRACK 1 \
      --set-default OTEL_SDK_DISABLED true
  '';

  meta = {
    description = "Context optimization layer for LLM applications";
    homepage = "https://github.com/headroomlabs-ai/headroom";
    license = lib.licenses.asl20;
    mainProgram = "headroom";
    platforms = lib.platforms.linux;
    broken = !stdenv.hostPlatform.isx86_64;
  };
}
