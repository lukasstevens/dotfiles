{ ... }:

{

  imports = [
    ./configuration.nix
  ];

  networking.hostName = "nixtop";

  programs.kdeconnect.enable = true;
}
