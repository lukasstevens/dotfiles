{ ... }:

{
  imports = [ ~/dotfiles/common.nix ];
  
  home.keyboard = {
    layout = "us";
    options = [ "compose:caps" ];
  };

}
