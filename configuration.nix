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
    kdeFrameworks.kwallet
    networkmanager
    tree
    vim
    wget
  ];

  programs.firejail.enable = true;

  services.compton = {
    enable = true;
    backend = "glx";
    vSync = true;
  };

  services.dbus.packages = [ pkgs.gnome3.dconf ];

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

  systemd.services.dnscrypt-proxy2.serviceConfig = {
    StateDirectory = "dnscrypt-proxy2";
  };

  # Enable backlight
  hardware.brightnessctl.enable = true;

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;

  # Enable the X11 windowing system.
  services.xserver = {
    enable = true;
    libinput.enable = true;
    desktopManager.xterm.enable = true;
    displayManager.lightdm.enable = true;
  };

  services.gnome3.gnome-keyring.enable = true;
  security.pam.services.lightdm.enableGnomeKeyring = true;

  users.mutableUsers = false;
  users.extraUsers.lukas = {
    home = "/home/lukas";
    createHome = true;
    isNormalUser = true;
    extraGroups = [ "audio" "wheel" "networkmanager" "video" "wireshark" ];
    hashedPassword = "INSERT HASHED PASSWORD HERE";
    shell = pkgs.zsh;
  };

  system.copySystemConfiguration = true;

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "20.09"; # Did you read the comment?
}
