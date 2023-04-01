{ pkgs, stdenv } :

stdenv.mkDerivation {
  pname = "base16-rofi-template";
  version = "for-mybase16-theme";

  src = ./.;

  installPhase = ''
    mkdir -p $out
    cp -r templates $out
    '';
}
