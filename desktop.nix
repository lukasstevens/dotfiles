{ ... }:

{
  imports = [ ~/dotfiles/common.nix ];
  
  home.keyboard = {
    layout = "us";
    options = [ "compose:caps" ];
  };

  xsession.initExtra = ''
xrandr --output DP-2 --mode 3440x1440 --primary
xrandr --output HDMI-4 --left-of DP-2 --auto
    '';
}
