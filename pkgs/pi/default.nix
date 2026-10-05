{ lib, buildNpmPackage, fetchzip, nodejs_24, makeWrapper, ripgrep, fd, jq }:

buildNpmPackage rec {
  pname = "pi-coding-agent";
  version = "1.0.0";

  src = fetchzip {
    url = "https://registry.npmjs.org/@earendil-works/pi-coding-agent/-/pi-coding-agent-${version}.tgz";
    hash = "sha256-0Y/IR2n4UAVMxV5Y3a7125MZENV0XRBtVtUhEgNhmoE=";
  };

  nodejs = nodejs_24;
  # Upstream omits integrity hashes for its own workspace packages.
  postPatch = ''
    ${jq}/bin/jq --slurpfile hashes ${./npm-integrities.json} '
      .packages |= with_entries(
        if $hashes[0][.key] then .value.integrity = $hashes[0][.key] else . end
      )
    ' npm-shrinkwrap.json > npm-shrinkwrap.json.new
    mv npm-shrinkwrap.json.new npm-shrinkwrap.json
    ${jq}/bin/jq 'del(.devDependencies)' package.json > package.json.new
    mv package.json.new package.json
  '';
  npmDepsHash = "sha256-gSAAY8ehyyzlVSj6E7YCTezZ4cL3MTIiwKdC+O1OnCQ=";
  npmFlags = [ "--ignore-scripts" ];
  dontNpmBuild = true;

  nativeBuildInputs = [ makeWrapper ];

  postFixup = ''
    wrapProgram "$out/bin/pi" \
      --prefix PATH : ${lib.makeBinPath [ nodejs_24 ripgrep fd ]} \
      --set PI_PACKAGE_DIR "$out/lib/node_modules/@earendil-works/pi-coding-agent" \
      --set PI_SUBAGENTS_PI_CODING_AGENT_PACKAGE_ROOT "$out/lib/node_modules/@earendil-works/pi-coding-agent" \
      --set-default PI_SKIP_VERSION_CHECK 1 \
      --set-default PI_TELEMETRY 0
  '';

  doInstallCheck = true;
  installCheckPhase = ''
    export HOME="$TMPDIR/pi-home"
    mkdir -p "$HOME"
    test "$("$out/bin/pi" --version)" = "${version}"
    "$out/bin/pi" mcp --help >/dev/null
  '';

  meta = {
    description = "Pi coding agent with built-in MCP integration";
    homepage = "https://pi.dev";
    license = lib.licenses.mit;
    mainProgram = "pi";
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
  };
}
