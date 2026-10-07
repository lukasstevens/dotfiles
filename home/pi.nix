{ config, pkgs, lib, ... }:

let
  pi = pkgs.callPackage ../pkgs/pi {};
  subagents = pkgs.callPackage ../pkgs/pi-subagents {};
  subagentsPath = "${subagents}/lib/node_modules/pi-subagents";
  isabelle = pkgs.callPackage ../pkgs/isabelle/with-mcp.nix {};
  pideMcp = isabelle.pideMcp;
  emptyJson = pkgs.writeText "pi-empty-settings.json" "{}";
in
{
  # On Linux the sandbox module can own the `pi` executable. Keep the native
  # package on macOS and when the wrapper is disabled or separately named.
  home.packages = lib.optional (!(lib.attrByPath
    [ "programs" "pi-bwrap" "enable" ] false config
    && lib.attrByPath [ "programs" "pi-bwrap" "exposeAsDefault" ] false config)) pi;
  home.sessionPath = lib.mkBefore [ "${config.home.profileDirectory}/bin" ];

  home.file.".pi/agent/skills/isabelle-pide-mcp".source = "${pideMcp.src}/.agents/skills";

  # Pi writes preferences and MCP settings itself, so keep these files mutable.
  home.activation.piConfiguration = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if [[ -z "''${DRY_RUN:-}" ]]; then
      mkdir -p "$HOME/.pi/agent"

      merge_pi_config() {
        local file="$1" source="$1" tmp
        shift
        [[ -e "$source" ]] || source=${emptyJson}
        tmp=$(mktemp "$file.XXXXXX")
        if ${pkgs.jq}/bin/jq "$@" "$source" > "$tmp"; then
          chmod 600 "$tmp"
          mv -f "$tmp" "$file"
        else
          rm -f "$tmp"
          return 1
        fi
      }

      merge_pi_config "$HOME/.pi/agent/settings.json" --arg package ${lib.escapeShellArg subagentsPath} '
        def packageSource: if type == "string" then . else .source // "" end;
        .packages = (
          ((.packages // []) | map(select(
            (packageSource | test("^(npm:)?pi-mcp-(extension|adapter)(@|$)|^(npm:)?pi-subagents(@|$)|/pi-subagents$")) | not
          ))) + [$package]
        )
      '

      merge_pi_config "$HOME/.pi/agent/mcp.json" \
        --arg command ${lib.escapeShellArg "${isabelle}/bin/isabelle"} \
        --arg identifier ${lib.escapeShellArg "Isabelle${isabelle.version}-pi"} '
          .mcpServers["isabelle-pide-mcp"] = {
            command: $command,
            args: ["pide_mcp"],
            env: { ISABELLE_IDENTIFIER: $identifier },
            exposure: "direct",
            timeout: 600
          }
        '
    fi
  '';
}
