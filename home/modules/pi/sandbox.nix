# Shared by Home Manager and the dotfiles development shell.
{ pkgs
, pi
, agent-sandbox
, homeDirectory ? "$HOME"
, configHome ? "${homeDirectory}/.config"
, meridianEnabled ? false
, sessionDir ? null
, extraRwDirs ? []
}:

let
  inherit (pkgs) lib;
  sandbox = agent-sandbox.lib.${pkgs.stdenv.hostPlatform.system};
  endpoint = import ../meridian/endpoint.nix;
  sandboxAgentDir = "${homeDirectory}/.local/state/pi/sandboxed";
  isabelleUserHome = "${homeDirectory}/.local/state/pi/isabelle-sandboxed";
in
sandbox.mkSandbox {
  pkg = pi;
  binName = "pi";
  outName = "pi-sandboxed";
  allowedPackages = sandbox.commonTools ++ [
    pkgs.isabelle-with-mcp
    # Isabelle's gnu-utils settings resolve tar from PATH during startup.
    pkgs.gnutar
  ]
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
  allowedHostPorts = if pkgs.stdenv.hostPlatform.isDarwin then null
    else lib.optionals meridianEnabled [ endpoint.port ];
  # Route HTTP(S) through the host-side proxy, which can use the host's
  # loopback DNS resolver. Direct DNS cannot reach it from Linux's netns.
  allowedDomains = { "*" = "*"; };
  rwDirs = [ sandboxAgentDir isabelleUserHome ]
    ++ lib.optional (sessionDir != null) sessionDir
    ++ extraRwDirs;
  roFiles = lib.optionals meridianEnabled [ "${configHome}/pi/meridian-models.json" ];
  env = {
    PI_CODING_AGENT_DIR = sandboxAgentDir;
    PI_CLIPBOARD_OSC52 = "1";
    ANTHROPIC_API_KEY = "\${ANTHROPIC_API_KEY:-}";
    OPENAI_API_KEY = "\${OPENAI_API_KEY:-}";
    GEMINI_API_KEY = "\${GEMINI_API_KEY:-}";
  } // lib.optionalAttrs (sessionDir != null) {
    PI_CODING_AGENT_SESSION_DIR = sessionDir;
  };
}
