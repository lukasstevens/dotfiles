{ ... }:

{
  imports = [ ~/dotfiles/home.nix ];
  
  xsession.initExtra = ''
xrandr --output DP1 --mode 2560x1440 --rate 59.95 --primary
(xrandr --output HDMI1 --off && sleep 0.2s && xrandr --output HDMI1 --right-of DP1 --auto)
    '';
}
