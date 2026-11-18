def --wrapped nix [...args: string] {
  let token_result = (^gh auth token | complete)
  if $token_result.exit_code == 0 and not ($token_result.stdout | str trim | is-empty) {
    let existing_config = ($env.NIX_CONFIG? | default "")
    let separator = if ($existing_config | is-empty) { "" } else { "\n" }
    with-env { NIX_CONFIG: $"($existing_config)($separator)access-tokens = github.com=($token_result.stdout | str trim)" } {
      ^nix ...$args
    }
  } else {
    ^nix ...$args
  }
}
