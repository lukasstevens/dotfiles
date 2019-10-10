{ stdenv, fetchFromGitHub }:

stdenv.mkDerivation rec {
  name = "i3blocks-contrib";

  src = fetchFromGitHub {
    owner = "vivien";
    repo = "i3blocks-contrib";
    rev = "21708edc3d12c1f37285e3e9363f6541be723599";
    sha256 = "0rj2q481mkbj3cawg7lsd6x0x0ii9jxnr327f8n3b2kvrdfyvzy6";
  };

  installPhase = "cp -r . $out";

  meta = with stdenv.lib; {
    description = "i3blocks-contrib directory";
    homepage = https://github.com/i3blocks-contrib;
  };
}

