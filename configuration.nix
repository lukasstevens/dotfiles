{ config, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking = {
    hostName = "nixos"; 
    networkmanager.enable = true;
    networkmanager.dns = "none";
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
    tree
    vim
    wget
  ];

  programs.firejail.enable = true;

  programs.adb.enable = true;

  services.dbus.packages = [ pkgs.dconf ];

  services.printing.enable = true;

  services.dnscrypt-proxy2 = {
    enable = true;
    settings = {
      ipv6_servers = true;
      require_dnssec = true;
      sources.public-resolvers = {
        urls = [
          "https://download.dnscrypt.info/resolvers-list/v2/public-resolvers.md"
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

  # Keyrings
  services.gnome3.gnome-keyring.enable = true;

  hardware.opengl = {
    enable = true;
    driSupport = true;
  };

  programs.sway.enable = true;

  users.mutableUsers = false;
  users.extraUsers.lukas = {
    home = "/home/lukas";
    createHome = true;
    isNormalUser = true;
    extraGroups = [ "adbusers" "audio" "wheel" "networkmanager" "video" "wireshark" ];
    hashedPassword = "$6$OrMJA8m9I$zzG6dHz/HO8mv8xIFU9yX5LweRLJY2GIzdQYa5RQXNFfSQCrTGwqhRpfXuG/qOqcYIEIL6jjeatS/CppqcbRy.";
    shell = pkgs.zsh;
  };

  system.copySystemConfiguration = true;

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "21.05"; # Did you read the comment?
}
