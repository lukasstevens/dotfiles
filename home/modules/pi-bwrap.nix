{ config, pkgs, lib, ... }:
let
  cfg = config.programs.pi-bwrap;
  home = config.home.homeDirectory;
  mkLauncher = import ./bwrap-launcher.nix { inherit pkgs lib; };
  wrapped = mkLauncher {
    name = if cfg.exposeAsDefault then "pi" else "pi-bwrap";
    command = "${cfg.package}/bin/pi";
    inherit home;
    # Share the actual Pi agent directory, including credentials and extensions.
    writablePaths = [ "${home}/.pi/agent" ];
    extraPackages = [ cfg.package ] ++ cfg.extraPackages;
    inherit (cfg) extraEnvironment;
  };
in
{
  options.programs.pi-bwrap = {
    enable = lib.mkEnableOption "Pi in a bubblewrap sandbox";
    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.callPackage ../../pkgs/pi {};
      description = "Pi package to run inside the sandbox.";
    };
    exposeAsDefault = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Install the wrapper as pi rather than pi-bwrap.";
    };
    extraPackages = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [];
      description = "Additional tools on the sandbox PATH.";
    };
    extraEnvironment = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = "Additional host environment variables to forward into the sandbox.";
    };
  };
  config = lib.mkIf cfg.enable {
    home.packages = [ wrapped ];
  };
}
