{ config, pkgs, lib, ... }:

{
  imports = [ ./home.nix ];

  home.homeDirectory = lib.mkForce /Users/lukas;

  home.stateVersion = "23.11";
}
