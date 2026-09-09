{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.internal.headroom;
  system = pkgs.stdenv.hostPlatform.system;
  package = inputs.self.packages.${system}.headroom;
  codexPackage = config.programs.codex.package;
  proxyPort = 8787;
  headroomDataDir = "${config.xdg.dataHome}/headroom";
  savingsEventsPath = "${headroomDataDir}/savings_events.jsonl";

  codexHeadroom = pkgs.writeShellApplication {
    name = "codex-headroom";
    runtimeInputs = [ pkgs.curl ];
    text = ''
      runtime_root="''${XDG_RUNTIME_DIR:-''${TMPDIR:-/tmp}}"
      work_dir="$(${pkgs.coreutils}/bin/mktemp -d "$runtime_root/codex-headroom.XXXXXX")"
      proxy_log="$work_dir/proxy.log"
      proxy_pid=""
      mkdir -p "$work_dir/state" "$work_dir/config"
      export HEADROOM_WORKSPACE_DIR="$work_dir/state"
      export HEADROOM_CONFIG_DIR="$work_dir/config"
      export HEADROOM_SAVINGS_EVENTS_PATH="${savingsEventsPath}"
      # Keep interactive startup bounded. Headroom leaves every model enabled
      # and lazily loads any model that cannot preload within this budget.
      export HEADROOM_EAGER_PRELOAD_TIMEOUT_SECONDS=30

      # ShellCheck cannot see that trap invokes this function.
      # shellcheck disable=SC2329
      cleanup() {
        if [ -n "$proxy_pid" ] && kill -0 "$proxy_pid" 2>/dev/null; then
          kill "$proxy_pid" 2>/dev/null || true
          wait "$proxy_pid" 2>/dev/null || true
        fi
        ${pkgs.coreutils}/bin/rm -rf -- "$work_dir"
      }
      trap cleanup EXIT INT TERM

      if curl --silent --fail "http://127.0.0.1:${toString proxyPort}/readyz" >/dev/null 2>&1; then
        echo "codex-headroom: port ${toString proxyPort} already has a Headroom proxy" >&2
        echo "codex-headroom: stop it before starting an isolated session" >&2
        exit 1
      fi

      ${lib.getExe package} proxy \
        --host 127.0.0.1 \
        --port ${toString proxyPort} \
        --memory \
        --memory-storage user \
        --memory-db-path "$work_dir/state/memory.db" \
        --code-aware \
        --no-telemetry \
        --no-subscription-tracking \
        >"$proxy_log" 2>&1 &
      proxy_pid=$!

      ready=0
      for _ in $(${pkgs.coreutils}/bin/seq 1 240); do
        if curl --silent --fail "http://127.0.0.1:${toString proxyPort}/readyz" >/dev/null 2>&1; then
          ready=1
          break
        fi
        if ! kill -0 "$proxy_pid" 2>/dev/null; then
          break
        fi
        ${pkgs.coreutils}/bin/sleep 0.25
      done

      if [ "$ready" -ne 1 ]; then
        echo "codex-headroom: proxy did not become ready" >&2
        ${pkgs.coreutils}/bin/tail -n 80 "$proxy_log" >&2 || true
        exit 1
      fi

      status=0
      ${lib.getExe codexPackage} \
        --config 'openai_base_url="http://127.0.0.1:${toString proxyPort}/v1"' \
        "$@" || status=$?
      exit "$status"
    '';
  };
in
{
  options.internal.headroom.enable = mkEnableOption "Headroom context optimization tooling";

  config = mkIf cfg.enable {
    home.sessionVariables.HEADROOM_SAVINGS_EVENTS_PATH = savingsEventsPath;

    home.packages = [
      package
      codexHeadroom
    ];
  };
}
