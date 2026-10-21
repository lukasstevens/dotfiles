{ config, lib, ... }:

{
  programs.zsh = import ./settings.nix { inherit config lib; };
}
