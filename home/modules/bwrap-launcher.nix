# Shared process sandbox for Nix-packaged coding agents (not a Home Manager module).
{ pkgs, lib }:
{ name, command, home, writablePaths, extraPackages ? [], extraEnvironment ? [] }:
let
  tools = with pkgs; [
    bashInteractive coreutils findutils gnugrep gnused gawk git ripgrep fd
  ];
  path = lib.makeBinPath (tools ++ extraPackages);
  nsswitch = pkgs.writeText "agent-nsswitch.conf" ''
    passwd: files
    group: files
    hosts: files dns
  '';
  # Explicitly forwarded values are also readable by agent subprocesses.
  environment = lib.unique ([
    "TERM" "COLORTERM" "LANG" "LC_ALL" "TZ"
    "HTTP_PROXY" "HTTPS_PROXY" "ALL_PROXY" "NO_PROXY"
    "http_proxy" "https_proxy" "all_proxy" "no_proxy"
    "ANTHROPIC_API_KEY" "ANTHROPIC_OAUTH_TOKEN" "ANTHROPIC_AUTH_TOKEN"
    "OPENAI_API_KEY" "GEMINI_API_KEY" "OPENROUTER_API_KEY"
    "OPENCODE_API_KEY" "COPILOT_GITHUB_TOKEN" "GROQ_API_KEY"
    "MISTRAL_API_KEY" "DEEPSEEK_API_KEY" "XAI_API_KEY"
  ] ++ extraEnvironment);
in
pkgs.writeShellApplication {
  inherit name;
  runtimeInputs = [ pkgs.coreutils ];
  text = ''
    # --workspace is a wrapper option; all remaining arguments go to the agent.
    workspace="$PWD"
    if [[ "''${1:-}" == --workspace ]]; then
      if [[ $# -lt 2 ]]; then
        printf 'Usage: %s [--workspace DIRECTORY] [agent arguments...]\n' "$0" >&2
        exit 2
      fi
      workspace="$2"
      shift 2
    fi
    workspace=$(realpath -e -- "$workspace")
    if [[ ! -d "$workspace" ]]; then
      printf 'Not a directory: %s\n' "$workspace" >&2
      exit 2
    fi
    # Binding these would replace the sandbox's private or read-only mounts.
    case "$workspace" in
      /|/nix|/nix/*|/etc|/etc/*|/dev|/dev/*|/proc|/proc/*|/sys|/sys/*|/run|/run/*|/tmp|/bin|/bin/*|/usr|/usr/*)
        printf 'Choose a workspace outside sandbox system directories: %s\n' "$workspace" >&2
        exit 2
        ;;
    esac

    writable_paths=( ${lib.escapeShellArgs writablePaths} )
    mkdir -p -- "''${writable_paths[@]}"

    args=(
      --unshare-all --share-net --die-with-parent --new-session
      --cap-drop ALL
      --clearenv
      --ro-bind /nix/store /nix/store
      --proc /proc
      --dev /dev
      --tmpfs /tmp
      --dir /run
      --dir /etc
      --dir ${lib.escapeShellArg home}
      --dir /bin
      --dir /usr/bin
      --symlink ${pkgs.bashInteractive}/bin/bash /bin/bash
      --symlink ${pkgs.bashInteractive}/bin/bash /bin/sh
      --symlink ${pkgs.coreutils}/bin/env /usr/bin/env
      --ro-bind ${nsswitch} /etc/nsswitch.conf
      --setenv HOME ${lib.escapeShellArg home}
      --setenv PATH ${lib.escapeShellArg path}
      --setenv SHELL /bin/bash
      --setenv XDG_CONFIG_HOME ${lib.escapeShellArg "${home}/.config"}
      --setenv XDG_DATA_HOME ${lib.escapeShellArg "${home}/.local/share"}
      --setenv XDG_STATE_HOME ${lib.escapeShellArg "${home}/.local/state"}
      --setenv XDG_CACHE_HOME ${lib.escapeShellArg "${home}/.cache"}
      --setenv SSL_CERT_FILE ${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt
      --setenv NODE_EXTRA_CA_CERTS ${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt
      --setenv LOCALE_ARCHIVE ${pkgs.glibcLocales}/lib/locale/locale-archive
      --setenv TERM xterm-256color
      --setenv LANG C.UTF-8
    )

    # Resolve host symlinks before mounting: their /run targets stay hidden.
    for file in /etc/resolv.conf /etc/hosts /etc/passwd /etc/group /etc/localtime; do
      if [[ -e "$file" ]]; then
        args+=( --ro-bind "$(realpath -e -- "$file")" "$file" )
      fi
    done

    for variable in ${lib.escapeShellArgs environment}; do
      if [[ -v "$variable" ]]; then
        args+=( --setenv "$variable" "''${!variable}" )
      fi
    done

    for directory in "''${writable_paths[@]}"; do
      args+=( --bind "$directory" "$directory" )
    done
    args+=( --bind "$workspace" "$workspace" --chdir "$workspace" )

    # Keep forwarded API keys out of bwrap's publicly visible command line.
    exec ${pkgs.bubblewrap}/bin/bwrap --args 3 \
      3< <(printf '%s\0' "''${args[@]}") -- ${lib.escapeShellArg command} "$@"
  '';
}
