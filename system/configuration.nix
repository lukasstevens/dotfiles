{ config, pkgs, lib, ... }:

{
  imports = [
    /etc/nixos/hardware-configuration.nix
  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking = {
    networkmanager.enable = true;
    networkmanager.dns = "none";

    firewall = {
      allowedTCPPorts = [
        24727 # AusweisApp2
      ];
      allowedUDPPorts = [
        24727 # AusweisApp2
      ];
    };
  };

  i18n = {
    defaultLocale = "en_GB.UTF-8";
    extraLocaleSettings = { LC_TIME = "de_DE.UTF-8"; };
  };

  # Set your time zone.
  time.timeZone = "Europe/Berlin";

  services.timesyncd.enable = true;

  environment.systemPackages = with pkgs; [
    gcc
    gnumake
    git
    networkmanager
    openvpn_24
    tree
    vim
    wget
  ];

  nixpkgs.overlays = [
    (self: super: {
      networkmanager-openvpn = super.networkmanager-openvpn.override { openvpn = pkgs.openvpn_24; };
    })
  ];

  services.udev.packages = [ pkgs.platformio ];

  services.gvfs.enable = true;

  programs.adb.enable = true;

  programs.firejail.enable = true;

  services.dbus.packages = [ pkgs.dconf ];

  services.printing.enable = true;

  services.dnscrypt-proxy2 = {
    enable = true;
    settings = {
      ipv6_servers = true;
      require_dnssec = true;
      sources.public-resolvers = {
        urls = [
          "https://raw.githubusercontent.com/DNSCrypt/dnscrypt-resolvers/master/v3/public-resolvers.md"
          "https://download.dnscrypt.info/resolvers-list/v3/public-resolvers.md"
        ];
        cache_file = "/var/lib/dnscrypt-proxy2/public-resolvers.md";
        minisign_key = "RWQf6LRCGA9i53mlYecO4IzT51TGPpvWucNSCh1CBM0QTaLn73Y7GFO3";
      };
    };
  };

  # Enable pipewire 
  security.rtkit.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-wlr ];
  };

  services.avahi = {
    enable = true;
    nssmdns = true;
    publish = {
      enable = true;
      addresses = true;
      workstation = true;
      userServices = true;
    };
  };

  virtualisation.docker = {
    enable = true;
    enableOnBoot = false;
  };

  # Keyrings
  services.gnome.gnome-keyring.enable = true;

  hardware.opengl = {
    enable = true;
    driSupport = true;
  };

  hardware.i2c.enable = true;

  programs.sway.enable = true;

  # Workaround for EDITOR being overwritten: https://github.com/nix-community/home-manager/issues/2751
  programs.zsh.enable = true;

  users.mutableUsers = false;
  users.extraUsers.lukas = {
    home = "/home/lukas";
    createHome = true;
    isNormalUser = true;
    extraGroups = [ "adbusers" "audio" "i2c" "networkmanager" "video" "wheel" "wireshark" ];
    hashedPassword = lib.removeSuffix "\n" (builtins.readFile /etc/nixos/hashed_password_lukas);
    shell = pkgs.zsh;
  };

  system.copySystemConfiguration = true;

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "21.05"; # Did you read the comment?
}
