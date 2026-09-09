{
  fetchFromHuggingFace,
  fetchurl,
  runCommand,
}:

let
  model =
    repoId: rev: sparseCheckout: hash:
    fetchFromHuggingFace {
      inherit
        repoId
        rev
        sparseCheckout
        hash
        ;
      backend = "lfs";
    };

  kompress = model "chopratejas/kompress-v2-base" "b1563631b35bfdcee37587ad530147497d820d4c" [
    "onnx/kompress-int8-wo.onnx"
  ] "sha256-Ds8oxftmud4+41MFbOcrxZJKZUVeUQ3jCm+F0DZBdgk=";
  modernBert = model "answerdotai/ModernBERT-base" "8949b909ec900327062f0ebf497f51aef5e6f0c8" [
    "config.json"
    "special_tokens_map.json"
    "tokenizer.json"
    "tokenizer_config.json"
  ] "sha256-3PoeeYdVHqynqQrSz5IBYD0bDKwBGUbD9FkbeLjl/JA=";
  techniqueRouter =
    model "chopratejas/technique-router-onnx" "27b0b4bfa510a1cff66d888072c0b807082721a8"
      [
        "config.json"
        "model_quantized.onnx"
        "tokenizer.json"
      ]
      "sha256-oPJpcQNxk4xeh/QWLkzSrJ6cLbm2Uk3/2g/ThtCRGxs=";
  siglipEncoder =
    model "chopratejas/siglip-image-encoder-onnx" "d0a9fbd66d4bd8c761bff592d44831f7c2ae184e"
      [
        "image_encoder_int8.onnx"
        "text_embeddings.npz"
      ]
      "sha256-zZAy61AcznOs2GdbSzwaOdwomm5uY55ryEXbIPasF18=";
  miniLmOnnx = model "Qdrant/all-MiniLM-L6-v2-onnx" "5f1b8cd78bc4fb444dd171e59b18f3a3af89a079" [
    "model.onnx"
    "tokenizer.json"
  ] "sha256-52KnWaHEXtj/SG8tKCLmfHsPSgci6fu9qvYRhVCQoxQ=";
  bgeSmall = model "qdrant/bge-small-en-v1.5-onnx-q" "52398278842ec682c6f32300af41344b1c0b0bb2" [
    "config.json"
    "model_optimized.onnx"
    "special_tokens_map.json"
    "tokenizer.json"
    "tokenizer_config.json"
    "vocab.txt"
  ] "sha256-k0b71IspkdCmh9mXsDTcWq50sS43KPUfkiVPJN+g87g=";
  sentenceTransformerBase = "https://huggingface.co/sentence-transformers/all-MiniLM-L6-v2/resolve/1110a243fdf4706b3f48f1d95db1a4f5529b4d41";
  sentenceTransformerFile =
    path: hash:
    fetchurl {
      url = "${sentenceTransformerBase}/${path}";
      inherit hash;
    };
  sentenceTransformer = runCommand "all-MiniLM-L6-v2-1110a243" { } ''
    mkdir -p "$out/1_Pooling"
    ln -s ${sentenceTransformerFile "1_Pooling/config.json" "sha256-S+RQ3eOwJzu5eHY3z70o/gSnumq502rEjpKxHjUP/CM="} "$out/1_Pooling/config.json"
    ln -s ${sentenceTransformerFile "config.json" "sha256-lT+cDUY0hrEKaHHML9WfIjsscBhPSYFefvvKtdiQi0E="} "$out/config.json"
    ln -s ${sentenceTransformerFile "config_sentence_transformers.json" "sha256-Bhyp05Zh1sbW3luif3mhzVdw6iR/jUZBKmikmNxayfM="} "$out/config_sentence_transformers.json"
    ln -s ${sentenceTransformerFile "model.safetensors" "sha256-U6pRFy0ULInZASzOFa5NbMDKaJWJURQ3nKy0+rEo2ds="} "$out/model.safetensors"
    ln -s ${sentenceTransformerFile "modules.json" "sha256-hOQMjgBsmx1sEi4Cy6mwJFgSC1+wyHt0bEHgIHz2Qs8="} "$out/modules.json"
    ln -s ${sentenceTransformerFile "sentence_bert_config.json" "sha256-/BmT/eCpXCTsbAIlOdQc9uL3yXIeVBXW+2iXRyqc1Lc="} "$out/sentence_bert_config.json"
    ln -s ${sentenceTransformerFile "special_tokens_map.json" "sha256-MD30WgNgnk6tBLw9wVNtCrGbU1jbaFtvPaEj0F7CAOM="} "$out/special_tokens_map.json"
    ln -s ${sentenceTransformerFile "tokenizer.json" "sha256-vlDDYo8r9bteOn8XsfdGEbJWGjon7qsF5aow9BFXIDc="} "$out/tokenizer.json"
    ln -s ${sentenceTransformerFile "tokenizer_config.json" "sha256-rLknaegZWqvSm3shN6nm1uJcR2pPFapDVcIzQmxhV2s="} "$out/tokenizer_config.json"
    ln -s ${sentenceTransformerFile "vocab.txt" "sha256-B+ztN1zsFE0nyQAkHz4zlHjeyVj5L928VR8pXJkgOKM="} "$out/vocab.txt"
  '';

  o200kBase = fetchurl {
    url = "https://openaipublic.blob.core.windows.net/encodings/o200k_base.tiktoken";
    hash = "sha256-RGqVOMtsNI41FhINfAiwn1fDZJXirP/+WaW/iwz7Gi0=";
  };
  cl100kBase = fetchurl {
    url = "https://openaipublic.blob.core.windows.net/encodings/cl100k_base.tiktoken";
    hash = "sha256-Ijkht27pm96ZW3/3OFE+7xAPtR0YyTWXoRO8/+hlsqc=";
  };
  p50kBase = fetchurl {
    url = "https://openaipublic.blob.core.windows.net/encodings/p50k_base.tiktoken";
    hash = "sha256-lLXKff9NAHZ7wlb90bJ+Wxc2HXuKX5aFR/nyPrcNIGk=";
  };
  r50kBase = fetchurl {
    url = "https://openaipublic.blob.core.windows.net/encodings/r50k_base.tiktoken";
    hash = "sha256-MGzSfwPBpxTspxCOA9ZrfcBCq+jCWLRMGZp+2YON2TA=";
  };
in
runCommand "headroom-models-0.36.0"
  {
    passthru = {
      inherit sentenceTransformer;
      modernBertRevision = "8949b909ec900327062f0ebf497f51aef5e6f0c8";
    };
  }
  ''
    hub="$out/hub"
    mkdir -p "$hub" "$out/tiktoken"

    link_snapshot() {
      repo="$1"
      rev="$2"
      source="$3"
      repo_dir="$hub/models--''${repo//\//--}"
      mkdir -p "$repo_dir/snapshots" "$repo_dir/refs"
      ln -s "$source" "$repo_dir/snapshots/$rev"
      printf '%s' "$rev" > "$repo_dir/refs/main"
    }

    link_snapshot "chopratejas/kompress-v2-base" "b1563631b35bfdcee37587ad530147497d820d4c" "${kompress}"
    link_snapshot "answerdotai/ModernBERT-base" "8949b909ec900327062f0ebf497f51aef5e6f0c8" "${modernBert}"
    link_snapshot "chopratejas/technique-router-onnx" "27b0b4bfa510a1cff66d888072c0b807082721a8" "${techniqueRouter}"
    link_snapshot "chopratejas/siglip-image-encoder-onnx" "d0a9fbd66d4bd8c761bff592d44831f7c2ae184e" "${siglipEncoder}"
    link_snapshot "Qdrant/all-MiniLM-L6-v2-onnx" "5f1b8cd78bc4fb444dd171e59b18f3a3af89a079" "${miniLmOnnx}"
    link_snapshot "qdrant/bge-small-en-v1.5-onnx-q" "52398278842ec682c6f32300af41344b1c0b0bb2" "${bgeSmall}"
    link_snapshot "sentence-transformers/all-MiniLM-L6-v2" "1110a243fdf4706b3f48f1d95db1a4f5529b4d41" "${sentenceTransformer}"

    ln -s "${o200kBase}" "$out/tiktoken/fb374d419588a4632f3f557e76b4b70aebbca790"
    ln -s "${cl100kBase}" "$out/tiktoken/9b5ad71b2ce5302211f9c61530b329a4922fc6a4"
    ln -s "${p50kBase}" "$out/tiktoken/ec7223a39ce59f226a68acc30dc1af2788490e15"
    ln -s "${r50kBase}" "$out/tiktoken/0ea1e91bbb3a60f729a8dc8f777fd2fc07cd8df4"
  ''
