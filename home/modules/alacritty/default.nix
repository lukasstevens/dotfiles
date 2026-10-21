{ pkgs, lib, ... }:

{
  programs.alacritty = {
    enable = true;
    settings = import ./settings.nix { inherit pkgs lib; };
  };
}
