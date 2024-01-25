{ ... }:

{
  imports = [ ./home.nix ];

  home.stateVersion = "21.11";
  
  wayland.windowManager.sway.config.output = {
    DVI-D-1 = {
      position = "0 360";
    };
    DP-3 = {
      position = "1920 0";
    };
  };
}
