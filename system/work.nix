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

  networking.extraHosts = ''
    127.0.0.1 www.reddit.com
    127.0.0.1 reddit.com
    127.0.0.1 teddit.net
    127.0.0.1 facebook.de
    127.0.0.1 facebook.com
    127.0.0.1 www.facebook.de
    127.0.0.1 www.facebook.com
    '';
}
