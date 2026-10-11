# Dotfiles

## Prerequisites

- Nix with `nix-command` and `flakes` enabled, Git, and sudo access.
- NixOS for Linux hosts; multi-user Nix and Homebrew on macOS.
- On macOS, a Linux builder for Linux dependencies unavailable from the binary cache.

Run commands from the repository root on the corresponding host.

## Custom packages

Custom package definitions live in `https://github.com/lukasstevens/nix-packages`.
This flake imports that checkout through the `nix-packages` input and applies its
`overlays.default` to both NixOS and macOS.

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
