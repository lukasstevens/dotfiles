{ lib, stdenvNoCC, fetchFromGitHub, isabelle }:

stdenvNoCC.mkDerivation rec {
  pname = "pide-mcp";
  version = "2025-2-8108cec";

  src = fetchFromGitHub {
    owner = "kappelmann";
    repo = "isabelle-pide-mcp";
    rev = "8108cec4dfff9378e45907deba580f18ce03794d";
    hash = "sha256-Pez6n8LA6LEKMfCykjdWmuLM9hkY7eEc6Y2fHYAbM/M=";
  };

  nativeBuildInputs = [ isabelle ];
  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    component="$out/${isabelle.dirname}/contrib/${pname}-${version}"
    mkdir -p "$component"
    cp -r . "$component/"
    chmod -R u+w "$component"
    export HOME="$TMPDIR/isabelle-home"
    mkdir -p "$HOME"
    isabelle components -u "$component"
    isabelle scala_build
    test -s "$component/lib/isabelle_pide_mcp.jar"

    runHook postInstall
  '';

  meta = {
    description = "Isabelle PIDE MCP component and agent skills";
    homepage = "https://github.com/kappelmann/isabelle-pide-mcp";
    license = lib.licenses.lgpl3Only;
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
  };
}
