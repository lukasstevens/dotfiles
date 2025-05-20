{ pkgs, stdenv, lib, isabelle }:

stdenv.mkDerivation rec {
  pname = "AFP";
  version = "2025";

  src = pkgs.fetchhg {
    url = "https://foss.heptapod.net/isa-afp/afp-2025";
    rev = "9dbcfccef70b13348a1a994faf454056968a429a";
    sha256 = "sha256-pshGU4KGldF1y6Zy16wqFO1bMaUDGldXTyoR5SdwAYk=";
  };

  nativeBuildInputs = [ isabelle ];

  buildPhase = ''
    export HOME=$TMP
    isabelle components -u $(pwd)/thys
  '';

  installPhase = ''
    dir=$out/Isabelle${isabelle.version}/contrib/${pname}-${version}
    mkdir -p $dir
    cp -r thys/* $dir/
    rm -rf $dir/Go/test
  '';

  meta = with lib; {
    description = "Archive of Formal Proofs";
    homepage = "https://isa-afp.org";
  };
}
