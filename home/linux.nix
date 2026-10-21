{ config, pkgs, ... }:
{
  imports = [
    ./modules/sway
  ];

  home.packages = with pkgs; [
    # Desktop programs
    evince
    lean
    nextcloud-client
    qpwgraph

    # Developer utilities
    cmake
    opencode
    ruby
    rustup

    # Command line utilities
    acpi
    ffmpeg-full
    gnupg
  ];

  fonts.fontconfig.enable = true;

  home.file = {
    ".latexmkrc".text = "$pdf_previewer = 'start evince';\n";
    ".XCompose".source = ./XCompose;
  };

  programs.zsh.shellAliases = {
    setclip = "wl-copy";
    getclip = "wl-paste";
    ls = "ls --color=auto";
  };

  xdg = {
    mime.enable = true; 
    mimeApps = {
      enable = true;
      defaultApplications = {
        "x-scheme-handler/http" = [ "firefox.desktop" ];
        "x-scheme-handler/https" = [ "firefox.desktop" ];
        "x-scheme-handler/mailto" = [ "thunderbird.desktop" ];
        "application/pdf" = [ "org.gnome.Evince.desktop" ];
        "image/jpeg" = [ "org.gnome.eog.desktop" ];
        "image/png" = [ "org.gnome.eog.desktop" ];
        "image/tiff" = [ "org.gnome.eog.desktop" ];
        "image/bmp" = [ "org.gnome.eog.desktop" ];
        "image/gif" = [ "org.gnome.eog.desktop" ];
      };
    };
    configFile."mimeapps.list".force = true;
  };

  services.network-manager-applet = {
    enable = true;
  };

  services.nextcloud-client = {
    enable = true;
    startInBackground = true;
  };

  services.kdeconnect = {
    enable = true;
    indicator = true;
  };

  gtk = {
    gtk4.theme = config.gtk.theme;
    enable = true;
    font = {
      name = "DejaVu Sans 11";
      package = pkgs.dejavu_fonts;
    };
    iconTheme = {
      name = "Adwaita";
      package = pkgs.adwaita-icon-theme;
    };
    theme = {
      name = "Arc-Dark";
      package = pkgs.arc-theme;
    };
  };

  qt = {
    enable = true;
    platformTheme.name = "gtk";
  };

  programs.firefox.configPath = ".mozilla/firefox";
}
