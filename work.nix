{ ... }:

{
  imports = [ ~/dotfiles/common.nix ];
  
  home.keyboard = {
    layout = "us";
    options = [ "compose:caps" ];
  };

  xsession.initExtra = ''
xrandr --output DP1 --mode 2560x1440 --primary
xrandr --output HDMI1 --right-of DP1 --mode 1920x1200
    '';
}
