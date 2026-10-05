{ pkgs, lib, isabelle }:

let
  baseIsabelle = if pkgs.stdenv.hostPlatform.isLinux then pkgs.unstable.isabelle else isabelle;
  pideMcp = pkgs.callPackage ./components/pide-mcp.nix { isabelle = baseIsabelle; };
  withComponents = baseIsabelle.withComponents (components:
    [ pideMcp ] ++ lib.optionals pkgs.stdenv.hostPlatform.isLinux [
      components.isabelle-linter
      (pkgs.unstable.callPackage ./components/afp.nix {})
    ]);
in
withComponents.overrideAttrs (old: {
  passthru = (old.passthru or {}) // {
    inherit pideMcp;
    inherit (baseIsabelle) version;
  };
})
