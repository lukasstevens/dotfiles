{ config, pkgs, lib, meridian, ... }:

let
  endpoint = import ./endpoint.nix;
  meridianPkgs = import meridian.inputs.nixpkgs {
    system = pkgs.stdenv.hostPlatform.system;
    config.allowUnfreePredicate = pkg: lib.getName pkg == "claude-code";
  };
  # Match Meridian's minimum-version selection, including its release manifest.
  claudeManifest = builtins.fromJSON (builtins.readFile
    "${meridian}/nix/pkgs/meridian/claude-code-manifest.json");
  claudeBase = if lib.versionOlder meridianPkgs.claude-code.version claudeManifest.version
    then meridianPkgs.claude-code.override { manifest = claudeManifest; }
    else meridianPkgs.claude-code;
  claude = if pkgs.stdenv.hostPlatform.isDarwin
    # The old Bun sandbox workaround is no longer needed (nixpkgs#566625).
    # Keep the version check enabled to verify the binary in the sandbox.
    then claudeBase.overrideAttrs { __noChroot = false; }
    else claudeBase;
  package = meridian.packages.${pkgs.stdenv.hostPlatform.system}.meridian.override {
    claude-code = claude;
  };
  claudeLauncher = pkgs.writeShellScriptBin "meridian-claude" ''
    exec ${lib.getExe claude} "$@"
  '';
in
{
  config = lib.mkMerge [
    {
      home.packages = [ package claudeLauncher ];

      xdg.configFile."meridian/plugins.json".text = builtins.toJSON {
        plugins = [
          {
            path = meridian.legacyPackages.${pkgs.stdenv.hostPlatform.system}
              .meridianPlugins.pi-scrub.path;
            enabled = true;
          }
        ];
      };

      xdg.configFile."pi/meridian-models.json".text = builtins.toJSON {
        providers.anthropic = {
          baseUrl = "http://${endpoint.host}:${toString endpoint.port}";
          apiKey = "x";
          headers."x-meridian-agent" = "pi";
        };
      };
    }
    (lib.mkIf pkgs.stdenv.hostPlatform.isDarwin {
      launchd.agents.meridian = {
        enable = true;
        config = {
          Label = "org.meridian.proxy";
          ProgramArguments = [ (lib.getExe package) ];
          WorkingDirectory = config.home.homeDirectory;
          RunAtLoad = true;
          KeepAlive = true;
          ThrottleInterval = 10;

          EnvironmentVariables = {
            HOME = config.home.homeDirectory;
            PATH = "/usr/bin:/bin:/usr/sbin:/sbin";
            MERIDIAN_HOST = endpoint.host;
            MERIDIAN_PORT = toString endpoint.port;
            MERIDIAN_PASSTHROUGH = "1";
            MERIDIAN_PLUGIN_CONFIG = "${config.xdg.configHome}/meridian/plugins.json";
          };

          StandardOutPath = "${config.home.homeDirectory}/Library/Logs/meridian.log";
          StandardErrorPath = "${config.home.homeDirectory}/Library/Logs/meridian.error.log";
        };
      };
    })
  ];
}
