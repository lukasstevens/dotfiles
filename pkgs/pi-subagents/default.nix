{ lib, buildNpmPackage, fetchzip, nodejs_24 }:

buildNpmPackage rec {
  pname = "pi-subagents";
  version = "0.74.0";

  src = fetchzip {
    url = "https://registry.npmjs.org/pi-subagents/-/pi-subagents-${version}.tgz";
    hash = "sha256-NCTn+mi7wnmF0rLhfSX4GtQ+8Rp96gHuIn1spSpb4ns=";
  };

  nodejs = nodejs_24;
  postPatch = ''
    cp ${./package-lock.json} package-lock.json
  '';
  npmDepsHash = "sha256-snXEIjTT4cyH+8JD4O5QyA4xjTPOoD8HJMuGis+mfxM=";
  npmFlags = [ "--ignore-scripts" "--legacy-peer-deps" ];
  dontNpmBuild = true;

  meta = {
    description = "Subagent delegation extension for Pi";
    homepage = "https://github.com/nicobailon/pi-subagents";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
  };
}
