nix() {
  local token nix_config
  token="$(gh auth token 2>/dev/null)" || token=""
  if [[ "$token" =~ ^[[:space:]]*$ ]]; then
    token=""
  fi
  if [[ -z "$token" ]]; then
    command nix "$@"
    return $?
  fi
  nix_config="${NIX_CONFIG-}"
  if [[ -n "$nix_config" ]]; then
    nix_config+=$'\n'
  fi
  NIX_CONFIG="${nix_config}access-tokens = github.com=$token" command nix "$@"
}
