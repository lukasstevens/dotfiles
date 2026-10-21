{ config, pkgs, lib, ... }:

{
  home.packages = with pkgs; [
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
    config = import ./settings.nix { inherit pkgs lib config; };
  };

  programs.waybar = {
    enable = true;
    settings = import ./waybar-settings.nix pkgs;
  };

  services.swayidle = {
    enable = true;
    events = {
      "before-sleep" = "${pkgs.swaylock}/bin/swaylock --color ${config.scheme.base00}";
      "lock" = "${pkgs.swaylock}/bin/swaylock --color ${config.scheme.base00}";
    };
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
}
