{ pkgs, stdenv, lib, isabelle }:

stdenv.mkDerivation rec {
  pname = "AFP";
  version = "2025-2";

  src = pkgs.fetchhg {
    url = "https://foss.heptapod.net/isa-afp/afp-2025-2";
    rev = "d73fde1397faa1257158b1f704d42975616d2d3f";
    sha256 = "sha256-xbWPBv0RpPXJ5qccmLk+u5AHIyOUOJ1jDaze88Nu0yw=";
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
