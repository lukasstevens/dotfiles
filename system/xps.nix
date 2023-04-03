{ ... }:

{

  imports = [
    ./configuration.nix
  ];

  hardware.bluetooth.enable = true;

  networking.hostName = "nixps";

  networking.firewall = {
    allowedTCPPorts = [
      7000 7100 # rpiplay
    ];
    allowedUDPPorts = [
      6000 6001 7011 # rpiplay
    ];
  };
}
