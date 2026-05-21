{ ... }:

{
  home.stateVersion = "21.11";
  
  wayland.windowManager.sway.config.output = {
    DP-4 = {
      position = "2560 0";
    };
    DP-3 = {
      position = "0 0";
    };
  };
}
