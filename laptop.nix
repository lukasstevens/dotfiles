{ ... }:

{
  imports = [ ~/dotfiles/common.nix ];
  
  home.keyboard = {
    layout = "de";
    options = [ "lvl3:caps" ];
  };

}
