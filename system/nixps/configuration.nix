{ ... }:

{
  imports = [ ./hardware-configuration.nix ];

  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  hardware.bluetooth.enable = true;

  services.blueman.enable = true;

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
