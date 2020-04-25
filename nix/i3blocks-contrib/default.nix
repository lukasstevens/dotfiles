{ stdenv, fetchFromGitHub, pkgs, ... }:

stdenv.mkDerivation rec {
  name = "i3blocks-contrib-fork";

  src = fetchFromGitHub {
    owner = "vivien";
    repo = "i3blocks-contrib";
    rev = "d600a2c481e489bacf1118e68063ccf3750da4a1";
    sha256 = "16lka1iqp6m1n6wiv5sgqybx1agl80g3j1jkl2kk2xb4wdx4zbch";
  };

  installPhase = ''
    make install PREFIX=$out
    '';
  propagatedBuildInputs = [ pkgs.perl ];

  meta = with stdenv.lib; {
    description = "i3blocks-contrib directory";
    homepage = https://github.com/lukasstevens/i3blocks-contrib;
  };
}

