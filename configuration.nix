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
  };

  i18n = {
    defaultLocale = "en_GB.UTF-8";
    extraLocaleSettings = { LC_TIME = "de_DE.UTF-8"; };
  };

  # Set your time zone.
  time.timeZone = "Europe/Berlin";

  environment.systemPackages = with pkgs; [
    acpilight
    gcc
    gnumake
    git
    kdeFrameworks.kwallet
    networkmanager
    tree
    vim
    wget
  ];

  services.compton = {
    enable = true;
    backend = "glx";
    vSync = true;
  };

  services.dbus.packages = [ pkgs.gnome3.dconf ];

  services.ntp.enable = true;

  services.printing.enable = true;

  services.dnscrypt-proxy.enable = true;

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;

  # Enable backlight
  hardware.brightnessctl.enable = true;

  # Enable the X11 windowing system.
  services.xserver = {
    enable = true;
    layout = "de";
    # For intel graphics
    # videoDrivers = [ "intel" ];
    # deviceSection = ''
    #   Option "TearFree" "True"
    # '';
    xkbOptions = "lv3:caps_switch";
    libinput.enable = true;
    displayManager.lightdm.enable = true;
  };

  security.pam.services.lightdm.enableKwallet = true;

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
  system.stateVersion = "19.09"; # Did you read the comment?
}
