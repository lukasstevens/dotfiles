{ ... }:

{
  imports = [ ./home.nix ];
  
  wayland.windowManager.sway.config.output = {
    "DP-1" = { pos = "0 0"; };
    "HDMI-A-1" = { pos = "2560 0"; };
  };
}
