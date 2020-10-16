{ stdenv, fetchFromGitHub, fetchpatch, autoreconfHook, gmp, libffi }:

stdenv.mkDerivation rec {
  pname = "polyml";
  version = "d68c6736402ea4704e1e154902a7ba14f58178aa";

  prePatch = stdenv.lib.optionalString stdenv.isDarwin ''
    substituteInPlace configure.ac --replace stdc++ c++
  '';

  #patches = [
  #  (fetchpatch {
  #    name = "new-libffi-FFI_SYSV.patch";
  #    url = "https://github.com/polyml/polyml/commit/ad32de7f181acaffaba78d5c3d9e5aa6b84a741c.patch";
  #    sha256 = "007q3r2h9kfh3c1nv0dyhipmak44q468ab9bwnz4kk4a2dq76n8v";
  #  })
  #];

  buildInputs = [ libffi gmp ];

  nativeBuildInputs = stdenv.lib.optional stdenv.isDarwin autoreconfHook;

  configureFlags = [
    "--enable-shared"
    "--with-system-libffi"
    "--with-gmp"
    "--enable-intinf-as-int"
  ];

  src = fetchFromGitHub {
    owner = "polyml";
    repo = "polyml";
    rev = "${version}";
    sha256 = "0qazadm87wmcwai7g319mgbny6b4jn0by3gfpiwcss1mmq7hamkz";
  };

  meta = with stdenv.lib; {
    description = "Standard ML compiler and interpreter";
    longDescription = ''
      Poly/ML is a full implementation of Standard ML.
    '';
    homepage = "https://www.polyml.org/";
    license = licenses.lgpl21;
    platforms = with platforms; (linux ++ darwin);
    maintainers = with maintainers; [ maggesi kovirobi ];
  };
}
