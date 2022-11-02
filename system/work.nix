{ pkgs, ... }:

{

  imports = [
    ./configuration.nix
  ];

  networking.hostName = "worknix";

  services.ntp = {
    enable = true;
    servers = [ "ntp1.in.tum.de" "ntp2.in.tum.de" ];
  };

  networking.firewall = {
    allowedTCPPorts = [ 123 ];
    allowedUDPPorts = [ 123 ];
  };
  
  services.printing.drivers = [ pkgs.gutenprint pkgs.hplip ];
}
