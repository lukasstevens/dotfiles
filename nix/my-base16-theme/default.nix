{ stdenv, base16-builder, fetchFromGitHub }:

stdenv.mkDerivation rec {
  pname = "my-base16-theme";
  version = "stable";

  src = fetchFromGitHub {
    owner = "lukasstevens";
    repo = "dotfiles";
    rev = "05eccbf9b7fb11c5523e838fff19e06987234219";
    sha256 = "1xl8smb1azxvxpvpxlk4ykp71kkbhjy2yjh64qhb3rhaqv7brz3b";
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
