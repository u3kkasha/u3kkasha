_:

{
  programs.nushell = {
    enable = true;
    settings = {
      show_banner = false;
      edit_mode = "vi";
    };
    extraConfig = ''
      # Load Doppler secrets if logged in
      try {
        if ("~/.doppler/config.yaml" | path exists) {
          load-env (doppler secrets download --format json | from json)
        }
      }

      # devenv shell integration
      $env._DEVENV_HOOK_UNTRUSTED = ""
      $env.config = ($env.config | upsert hooks.env_change.PWD (
          ($env.config | get -o hooks.env_change.PWD | default []) | append {||
              if ("DEVENV_ROOT" in $env) {
                  if not ($env.PWD == $env.DEVENV_ROOT or ($env.PWD | str starts-with ($env.DEVENV_ROOT + "/"))) {
                      $env.PWD | save --force ($env.DEVENV_ROOT + "/.devenv/exit-dir")
                      exit
                  }
                  return
              }
              let result = (^devenv hook-should-activate | complete)
              if ($result.stderr | str trim) != "" { print -e $result.stderr }
              if $result.exit_code == 0 {
                  let dir = ($result.stdout | str trim)
                  if $dir != "" {
                      do { cd $dir; ^devenv shell }
                      $env._DEVENV_HOOK_UNTRUSTED = ""
                      let exit_dir_file = ($dir + "/.devenv/exit-dir")
                      if ($exit_dir_file | path exists) {
                          let target_dir = (open $exit_dir_file | str trim)
                          rm -f $exit_dir_file
                          if ($target_dir | path exists) { cd $target_dir }
                      }
                  } else {
                      $env._DEVENV_HOOK_UNTRUSTED = ""
                  }
              } else {
                  $env._DEVENV_HOOK_UNTRUSTED = $env.PWD
              }
          }
      ))
      $env.config = ($env.config | upsert hooks.pre_prompt (
          ($env.config | get -o hooks.pre_prompt | default []) | append {||
              let untrusted = ($env | get -o _DEVENV_HOOK_UNTRUSTED | default "")
              if $untrusted == "" { return }
              if ("DEVENV_ROOT" in $env) { return }
              let result = (^devenv hook-should-activate | complete)
              if $result.exit_code == 0 {
                  let dir = ($result.stdout | str trim)
                  if $dir != "" {
                      do { cd $dir; ^devenv shell }
                      $env._DEVENV_HOOK_UNTRUSTED = ""
                      let exit_dir_file = ($dir + "/.devenv/exit-dir")
                      if ($exit_dir_file | path exists) {
                          let target_dir = (open $exit_dir_file | str trim)
                          rm -f $exit_dir_file
                          if ($target_dir | path exists) { cd $target_dir }
                      }
                  }
              }
          }
      ))

      # Export GitHub token from gh if available
      if (which gh | is-not-empty) {
          $env.GITHUB_TOKEN = (do { ^gh auth token } | complete | get -i stdout | str trim)
      }
    '';
  };
}
