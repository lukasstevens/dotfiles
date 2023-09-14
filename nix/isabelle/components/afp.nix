{ stdenv, lib, isabelle }:

stdenv.mkDerivation rec {
  pname = "AFP";
  version = "2023";

  src = fetchTarball {
    url = "https://foss.heptapod.net/isa-afp/afp-devel/-/archive/580c72858b498ea8ba763e81b56a567871257384/afp-devel-580c72858b498ea8ba763e81b56a567871257384.tar.gz";
    sha256 = "1mjybqwwsafznim2lxvdzgqn34kd96agbf2q63zv4h260f81knlk";
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
