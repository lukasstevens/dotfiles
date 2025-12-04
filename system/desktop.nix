{ pkgs, ... }:

{

  imports = [
    ./configuration.nix
  ];

  networking.hostName = "nixtop";

  programs.kdeconnect.enable = true;

  networking.firewall.allowedUDPPorts = [
    8912 8930 # IsarLight
  ];

  networking.extraHosts = ''
    192.168.1.237 hass.nixpi.lan
    192.168.1.237 zigbee.nixpi.lan
    ''
    + ''
    0.0.0.0 www.reddit.com
    0.0.0.0 reddit.com
    0.0.0.0 old.reddit.com
    ''
    ;

  virtualisation.libvirtd.enable = true;
  users.extraUsers."lukas".extraGroups = [ "libvirtd" ];
  networking.firewall.checkReversePath = true;

  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  powerManagement.powerDownCommands =
    let
      behringer-id = "1397:0508";
    in
    # The Behringer interface prevents suspending so we unbind it in advance.
    ''
    bus_path=$(${pkgs.usbutils}/bin/lsusb -tvv | ${pkgs.gawk}/bin/awk '/${behringer-id}/ { getline; print gensub(/.*devices\/([0-9\-\.]*)/, "\\1", "g", $1); exit; }')
    echo "$bus_path" > /sys/bus/usb/drivers/usb/unbind
    '';
}
