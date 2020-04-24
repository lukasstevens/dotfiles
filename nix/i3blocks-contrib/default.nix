{ stdenv, fetchFromGitHub }:

stdenv.mkDerivation rec {
  name = "i3blocks-contrib-fork";

  src = fetchFromGitHub {
    owner = "lukasstevens";
    repo = "i3blocks-contrib";
    rev = "f390e0ee829938016aa827488b51aee1d426ccd2";
    sha256 = "0jrm5fp97r4311r0a0gl5m11z1h8ipy79lrq8yk25fvv58gpf9c8";
  };

  installPhase = "cp -r . $out";

  meta = with stdenv.lib; {
    description = "i3blocks-contrib directory";
    homepage = https://github.com/lukasstevens/i3blocks-contrib;
  };
}

