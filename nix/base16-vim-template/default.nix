{ pkgs, stdenv } :

stdenv.mkDerivation {
  pname = "base16-vim-template";
  version = "for-mybase16-theme";

  src = pkgs.fetchFromGitHub {
    owner = "chriskempson";
    repo = "base16-vim";
    rev = "6191622d5806d4448fa2285047936bdcee57a098";
    sha256 = "1qz21jizcy533mqk9wff1wqchhixkcfkysqcqs0x35wwpbri6nz8";
  };

  installPhase = ''
    mkdir -p $out
    cp -r templates $out
    '';
}
