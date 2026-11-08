# Dotfiles

## Prerequisites

- Nix with `nix-command` and `flakes` enabled, Git, and sudo access.
- NixOS for Linux hosts; multi-user Nix and Homebrew on macOS.
- On macOS, a Linux builder for Linux dependencies unavailable from the binary cache.

Run commands from the repository root on the corresponding host.

## Custom packages

Custom package definitions live in the `inputs/nix-packages` Git submodule, sourced from
`https://github.com/lukasstevens/nix-packages`. Initialize it after cloning:

```sh
git submodule update --init --recursive
```

Alternatively, clone this repository with `git clone --recurse-submodules`.
The flake imports `path:./inputs/nix-packages` and applies its `overlays.default` to both
NixOS and macOS. It enables submodule inclusion when Nix fetches this repository.

## NixOS

Use `nixps` or `nixtop` as the host:

```sh
HOST=nixps
nix build ".#nixosConfigurations.${HOST}.config.system.build.toplevel"
sudo nixos-rebuild switch --flake ".#${HOST}"
```

## macOS

```sh
nix build .#darwinConfigurations.Lukass-MacBook-Pro.system
sudo darwin-rebuild switch --flake .#Lukass-MacBook-Pro
```

For initial installation, use the tool from the build result instead:

```sh
sudo ./result/sw/bin/darwin-rebuild switch --flake .#Lukass-MacBook-Pro
```

## Sandboxed Pi for this repository

The `agent-sandbox` input uses the `inputs/agent-sandbox.nix` Git submodule from
`https://github.com/lukasstevens/agent-sandbox.nix`, via `path:./inputs/agent-sandbox.nix`.
The submodule initialization command above initializes both submodules.

From the repository root:

```sh
nix develop
pi-sandboxed
```

Export the provider key you use (`ANTHROPIC_API_KEY`, `OPENAI_API_KEY`, or
`GEMINI_API_KEY`) before launching. Alternatively, authenticate outside the
sandbox using its dedicated state directory:

```sh
PI_CODING_AGENT_DIR="$HOME/.local/state/pi/dotfiles" pi
```

Provider keys are passed at runtime, not stored in Nix. Local subagents inherit
the sandbox restrictions.
