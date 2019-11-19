{ ... }:

{
  imports = [ ~/dotfiles/common.nix ];
  
  home.keyboard = {
    layout = "us";
    options = [ "compose:caps" ];
  };

  xsession.initExtra = ''
xrandr --output DP-1 --mode 2560x1440 --primary
xrandr --output HDMI-1 --right-of DP-1 --auto
    '';
}
