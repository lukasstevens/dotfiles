{ ... }:

{

  imports = [
    ./configuration.nix
  ];

  networking.hostName = "nixtop";

  programs.kdeconnect.enable = true;

  networking.firewall.allowedUDPPorts = [
    8912 8930 # IsarLight
  ];

  virtualisation.libvirtd.enable = true;
  users.extraUsers."lukas".extraGroups = [ "libvirtd" ];
  networking.firewall.checkReversePath = true;
}
