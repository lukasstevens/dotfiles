{ stdenv, lib, isabelle }:

stdenv.mkDerivation rec {
  pname = "AFP";
  version = "2023";

  src = fetchTarball {
    url = "https://foss.heptapod.net/isa-afp/afp-2023/-/archive/b656d667755f1947ccfbf00c7f70ec6ca3d414a6/afp-2023-b656d667755f1947ccfbf00c7f70ec6ca3d414a6.tar.gz";
    sha256 = "1nc9gjyjr6jmdhansix8kf66y9v5byi972p70wq9411k25rmf125";
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
