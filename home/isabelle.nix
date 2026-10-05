{ pkgs, ... }:

{
  home.packages = [ (pkgs.callPackage ../pkgs/isabelle/with-mcp.nix {}) ];
}
