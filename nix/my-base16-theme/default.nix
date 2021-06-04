{ stdenv, base16-builder, fetchFromGitHub }:

stdenv.mkDerivation rec {
  pname = "my-base16-theme";
  version = "stable";

  src = fetchFromGitHub {
    owner = "lukasstevens";
    repo = "dotfiles";
    rev = "e7a4a1139a1a714366f2fd4ba34b29b1c8363713";
    sha256 = "1b7iqqr77f0k1qwv68jk71bpxlyyc446s1qsswr6fbjzlvh787pr";
  };

  nativeBuildInputs = [
    base16-builder
  ];

  buildPhase = ''
    pushd colors
    HOME=(mktemp -d) make
    popd
    '';

  installPhase = ''
    mkdir -p $out/share
    cp colors/my-base16-dark-theme.el $out/share
    cp colors/my-base16.sh $out/share
    cp colors/my-base16.vim $out/share
    '';
}
