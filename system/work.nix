{ pkgs, ... }:

{

  imports = [
    ./configuration.nix
  ];

  networking.hostName = "worknix";

  services.timesyncd.servers = [
    "ntp1.lrz.de"
    "ntp2.lrz.de"
    "ntp.lrz.de"
    "ntp3.lrz.de"
  ];

  networking.firewall = {
    allowedTCPPorts = [ 123 ];
    allowedUDPPorts = [ 123 ];
  };
  
  services.printing.drivers = [ pkgs.gutenprint pkgs.hplip ];
}
