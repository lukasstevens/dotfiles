{ pkgs, stdenv } :

stdenv.mkDerivation {
  pname = "base16-shell-template";
  version = "for-mybase16-theme";

  src = pkgs.fetchFromGitHub {
    owner = "chriskempson";
    repo = "base16-shell";
    rev = "ce8e1e540367ea83cc3e01eec7b2a11783b3f9e1";
    sha256 = "1yj36k64zz65lxh28bb5rb5skwlinixxz6qwkwaf845ajvm45j1q";
  };

  installPhase = ''
    mkdir -p $out
    cp -r templates $out
    '';
}
