{ pkgs, stdenv } :

stdenv.mkDerivation {
  pname = "base16-rofi-template";
  version = "for-mybase16-theme";

  src = pkgs.fetchFromGitHub {
    owner = "tinted-theming";
    repo = "base16-rofi";
    rev = "3f64a9f8d8cb7db796557b516682b255172c4ab4";
    sha256 = "03y4ydnd6sijscrrp4qdvckrckscd39r8gyhpzffs60a1w4n76j5";
  };

  installPhase = ''
    mkdir -p $out
    cp -r templates $out
    '';
}
