{ config, pkgs, lib, agent-sandbox, ... }:

let
  pi = pkgs.pi.withExtensions (extensions: [ extensions.subagents ]);
  isabelle = pkgs.isabelle-with-mcp;
  pideMcp = isabelle.pideMcp;
  emptyJson = pkgs.writeText "pi-empty-settings.json" "{}";
  endpoint = import ../meridian/endpoint.nix;
  sandboxAgentDir = "${config.home.homeDirectory}/.local/state/pi/sandboxed";
  isabelleUserHome = "${config.home.homeDirectory}/.local/state/pi/isabelle-sandboxed";
  sandbox = agent-sandbox.lib.${pkgs.stdenv.hostPlatform.system};
  piSandboxed = sandbox.mkSandbox {
    pkg = pi;
    binName = "pi";
    outName = "pi-sandboxed";
    allowedPackages = sandbox.commonTools ++ [ isabelle ]
      # Isabelle queries macOS hardware through sysctl when starting sessions.
      ++ lib.optionals pkgs.stdenv.hostPlatform.isDarwin [ pkgs.darwin.system_cmds ];
    allowNix = true;
    # Pi subagents use local UNIX sockets.
    allowUnixSockets = true;
    # Allow parallel runtime synchronization without opening existing host semaphores.
    darwinPosixSemaphoreAccess =
      if pkgs.stdenv.hostPlatform.isDarwin then "create-unlink" else "none";
    # macOS shares the host network: Isabelle's dynamic prover connections
    # require open networking, including arbitrary loopback ports/listeners.
    allowedHostPorts = if pkgs.stdenv.hostPlatform.isDarwin then null else [ endpoint.port ];
    allowedDomains = null;
    rwDirs = [ sandboxAgentDir isabelleUserHome ];
    roFiles = [ "${config.xdg.configHome}/pi/meridian-models.json" ];
    env = {
      PI_CODING_AGENT_DIR = sandboxAgentDir;
      PI_CLIPBOARD_OSC52 = "1";
      ANTHROPIC_API_KEY = "\${ANTHROPIC_API_KEY:-}";
      OPENAI_API_KEY = "\${OPENAI_API_KEY:-}";
      GEMINI_API_KEY = "\${GEMINI_API_KEY:-}";
    };
  };
in
{
  home.packages = [ pi piSandboxed ];
  home.sessionPath = lib.mkBefore [ "${config.home.profileDirectory}/bin" ];

  home.file = {
    ".pi/agent/extensions/meridian-session-affinity.ts".source = ./meridian-session-affinity.ts;
    ".local/state/pi/sandboxed/extensions/meridian-session-affinity.ts".source = ./meridian-session-affinity.ts;
    ".pi/agent/skills/isabelle-pide-mcp".source = "${pideMcp.src}/.agents/skills";
    ".local/state/pi/sandboxed/skills/isabelle-pide-mcp".source = "${pideMcp.src}/.agents/skills";
    ".local/state/pi/sandboxed/models.json".source =
      config.lib.file.mkOutOfStoreSymlink "${config.xdg.configHome}/pi/meridian-models.json";
    ".local/state/pi/isabelle-sandboxed/.isabelle/Isabelle${isabelle.version}-pi-sandboxed/etc/settings".text = ''
      # Keep Isabelle's temporary files inside its dedicated sandbox state.
      ISABELLE_TMP_PREFIX="$USER_HOME/tmp"
    '';
    ".local/state/pi/sandboxed/mcp.json".text = builtins.toJSON {
      mcpServers.isabelle-pide-mcp = {
        command = "${isabelle}/bin/isabelle";
        args = [ "pide_mcp" ];
        env = {
          ISABELLE_IDENTIFIER = "Isabelle${isabelle.version}-pi-sandboxed";
          # Isabelle derives its user settings/heaps directory from USER_HOME.
          # Do not share writable Isabelle settings with unsandboxed processes.
          USER_HOME = isabelleUserHome;
          # The JVM otherwise uses a macOS host temp directory denied by the sandbox.
          JDK_JAVA_OPTIONS = "-Djava.io.tmpdir=\${TMPDIR}";
        };
        exposure = "direct";
        timeout = 600;
      };
    };
  };

  # Pi writes preferences and MCP settings itself, so keep these files mutable.
  home.activation.piConfiguration = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if [[ -z "''${DRY_RUN:-}" ]]; then
      mkdir -p "$HOME/.pi/agent" ${lib.escapeShellArg isabelleUserHome}

      merge_pi_config() {
        local file="$1" source="$1" tmp
        shift
        [[ -e "$source" ]] || source=${emptyJson}
        tmp=$(mktemp "$file.XXXXXX")
        if ${pkgs.jq}/bin/jq "$@" "$source" > "$tmp"; then
          chmod 600 "$tmp"
          mv -f "$tmp" "$file"
        else
          rm -f "$tmp"
          return 1
        fi
      }

      # Selected extensions now load through the composed launcher. Remove old
      # managed entries while preserving unrelated user packages and settings.
      merge_pi_config "$HOME/.pi/agent/settings.json" '
        def packageSource: if type == "string" then . else .source // "" end;
        .packages = (
          ((.packages // []) | map(select(
            (packageSource | test("^(npm:)?pi-mcp-(extension|adapter)(@|$)|^(npm:)?pi-subagents(@|$)|/pi-subagents$")) | not
          )))
        )
      '

      merge_pi_config "$HOME/.pi/agent/mcp.json" \
        --arg command ${lib.escapeShellArg "${isabelle}/bin/isabelle"} \
        --arg identifier ${lib.escapeShellArg "Isabelle${isabelle.version}-pi"} '
          .mcpServers["isabelle-pide-mcp"] = {
            command: $command,
            args: ["pide_mcp"],
            env: { ISABELLE_IDENTIFIER: $identifier },
            exposure: "direct",
            timeout: 600
          }
        '
    fi
  '';
}
