{ config, pkgs, lib, meridian, ... }:

let
  endpoint = import ./endpoint.nix;
  package = meridian.packages.${pkgs.stdenv.hostPlatform.system}.meridian;
in
{
  config = lib.mkMerge [
    {
      home.packages = [ package ];

      xdg.configFile."pi/meridian-models.json".text = builtins.toJSON {
        providers.anthropic = {
          baseUrl = "http://${endpoint.host}:${toString endpoint.port}";
          apiKey = "x";
          headers."x-meridian-agent" = "pi";
        };
      };
    }
    (lib.mkIf pkgs.stdenv.hostPlatform.isDarwin {
      # Run outside the sandbox so Claude credentials remain on the host.
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
          };

          StandardOutPath = "${config.home.homeDirectory}/Library/Logs/meridian.log";
          StandardErrorPath = "${config.home.homeDirectory}/Library/Logs/meridian.error.log";
        };
      };
    })
  ];
}
