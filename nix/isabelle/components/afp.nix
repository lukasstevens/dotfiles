{ stdenv, lib, isabelle }:

stdenv.mkDerivation rec {
  pname = "AFP";
  version = "2024";

  src = fetchTarball {
    url = "https://foss.heptapod.net/isa-afp/afp-2024/-/archive/2e1718ddcc1f102feba1fa8f9fcb585fd79381ad/afp-2024-2e1718ddcc1f102feba1fa8f9fcb585fd79381ad.tar.gz";
    sha256 = "14rzr7ckpbn113jv0igikq4bsf3ac0735p384nmn6agys5lrvkkh";
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
  '';

  meta = with lib; {
    description = "Archive of Formal Proofs";
    homepage = "https://isa-afp.org";
  };
}
