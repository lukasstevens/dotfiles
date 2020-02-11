{ ... }:

{
  imports = [ ~/dotfiles/common.nix ];
  
  home.keyboard = {
    layout = "de";
    options = [ "lvl3:caps" ];
  };

  xsession.initExtra = ''
xrandr --output DP-1 --mode 3440x1440 --primary
xrandr --output HDMI-4 --left-of DP-1 --auto
    '';
}
