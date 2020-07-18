{ ... }:

{
  imports = [ ~/dotfiles/home.nix ];
  
  xsession.initExtra = ''
pulseeffects --gapplication-service &
xrandr --output DP-3 --mode 3440x1440 --primary
xrandr --output DVI-D-1 --left-of DP-3
    '';
}
