{ pkgs }:

pkgs.pi.withExtensions (extensions: [ extensions.subagents extensions.processes ])
