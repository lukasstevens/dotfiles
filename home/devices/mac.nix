{ config, pkgs, lib, ... }:

{
  home.homeDirectory = lib.mkForce /Users/lukas;

  home.stateVersion = "23.11";
}
