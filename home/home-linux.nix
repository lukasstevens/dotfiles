{ config, pkgs, lib, base16, firefox-addons, ... }:
{
  imports = [
    ./modules/opencode-bwrap.nix
  ];

  home.packages = with pkgs; [
    # Desktop programs
    evince
    (pkgs.unstable.isabelle.withComponents (components: [
      components.isabelle-linter
      (pkgs.unstable.callPackage ../pkgs/isabelle/components/afp.nix {})
    ]))
    pkgs.unstable.keepassxc
    lean
    nextcloud-client
    pkgs.unstable.signal-desktop
    pkgs.unstable.telegram-desktop
    thunderbird

    # Developer utilities
    cmake
    ruby
    rustup

    # Command line utilities
    acpi
    ffmpeg-full
    gnupg

    # Window manager
    glibcLocales
    grim
    hicolor-icon-theme
    playerctl
    slurp
    swaylock
    swayidle
    wl-clipboard
    mako
    wofi 
    qt5.qtwayland
  ];

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

  wayland.windowManager.sway = {
    enable = true;
    systemd.enable = true;
    xwayland = true;
    wrapperFeatures.gtk = true;
    extraSessionCommands = ''
      export SDL_VIDEODRIVER=wayland
      export QT_QPA_PLATFORM=wayland
      export QT_WAYLAND_DISABLE_WINDOWDECORATION=1
      export _JAVA_AWT_WM_NONREPARENTING=1
      export MOZ_ENABLE_WAYLAND=1
      export XDG_SESSION_TYPE=wayland
      export XDG_CURRENT_DESKTOP=sway
      '';
      config = import ./sway/settings.nix { inherit pkgs lib config; };
  };

  programs.waybar = {
    enable = true;
    settings = import ./sway/waybar-settings.nix pkgs;
  };

  services.swayidle = {
    enable = true;
    events = [ 
      { event = "before-sleep"; command = "${pkgs.swaylock}/bin/swaylock --color ${config.scheme.base00}"; }
      { event = "lock"; command = "${pkgs.swaylock}/bin/swaylock --color ${config.scheme.base00}"; }
    ];
  };

  services.swayosd = {
    enable = true;
    stylePath = "${pkgs.arc-theme}/share/themes/Arc-Dark/gtk-3.0/gtk-dark.css";
    topMargin = 0.5;
  };

  services.wlsunset = {
    enable = true;
    temperature.day = 6500;
    temperature.night = 3500;
    latitude = "55.4";
    longitude = "12.3";
  };

  programs.firefox = {
    enable = true;
    package = pkgs.firefox;
    profiles."lukas" = {
      extensions.packages = with firefox-addons.packages.${pkgs.system}; [
        consent-o-matic
        ublock-origin
        umatrix
        keepassxc-browser
      ];
    };
  };

  programs.opencode-bwrap = {
    enable = true;
    exposeAsDefault = true;
  };
}
