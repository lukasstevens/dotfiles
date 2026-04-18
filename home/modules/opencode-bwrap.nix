{ config, pkgs, lib, ... }:

let
  cfg = config.programs.opencode-bwrap;
  home = config.home.homeDirectory;

  bwrapArgs = [
    "--unshare-all"
    "--share-net"
    "--die-with-parent"
    "--new-session"
    "--ro-bind /bin /bin"
    "--dev-bind /dev /dev"
    "--ro-bind /etc /etc"
    "--ro-bind-try /lib64 /lib64"
    "--ro-bind-try /lib32 /lib32"
    "--ro-bind /nix /nix"
    "--proc /proc"
    "--ro-bind /run /run"
    "--tmpfs /tmp"
    "--ro-bind /usr /usr"
    "--bind ${home}/.local/share/opencode ${home}/.local/share/opencode"
    "--bind ${home}/.local/state/opencode ${home}/.local/state/opencode"
    "--bind ${home}/.cache/opencode ${home}/.cache/opencode"
    "--bind ${home}/.config/opencode ${home}/.config/opencode"
    "--bind \"$PWD\" \"$PWD\""
  ];
  opencodeWrapped = pkgs.writeShellScriptBin "opencode" ''
    exec ${pkgs.bubblewrap}/bin/bwrap ${lib.concatStringsSep " " bwrapArgs} -- ${pkgs.opencode}/bin/opencode "$@"
  '';

in
{
  options.programs.opencode-bwrap = {
    enable = lib.mkEnableOption "opencode wrapped in bubblewrap sandbox";

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.opencode;
    };

    exposeAsDefault = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether to expose wrapped opencode as `opencode` in PATH";
    };
  };

  config = lib.mkIf cfg.enable {

    # 1. Install wrapper
    home.packages =
      if cfg.exposeAsDefault
      then [ opencodeWrapped pkgs.bubblewrap ]
      else [ pkgs.bubblewrap ];

    # 2. Ensure directories exist (important for bwrap bind mounts)
    systemd.user.tmpfiles.rules = [
      "d ${home}/.local/share/opencode 0755 - - -"
      "d ${home}/.local/state/opencode 0755 - - -"
      "d ${home}/.cache/opencode 0755 - - -"
      "d ${home}/.config/opencode 0755 - - -"
    ];
  };
}
