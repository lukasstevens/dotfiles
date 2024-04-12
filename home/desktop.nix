{ ... }:

{
  imports = [ ./home.nix ];

  home.stateVersion = "21.11";
  
  wayland.windowManager.sway.config.output = {
    DP-2 = {
      position = "0 360";
    };
    DP-1 = {
      position = "1920 0";
    };
  };
}
