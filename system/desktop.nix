{ ... }:

{

  imports = [
    ./configuration.nix
  ];

  networking.hostName = "nixtop";

  services.kdeconnect.enable = true;
}
