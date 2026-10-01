# Dotfiles

## Prerequisites

- Nix with `nix-command` and `flakes` enabled, Git, and sudo access.
- NixOS for Linux hosts; multi-user Nix and Homebrew on macOS.
- On macOS, a Linux builder for Linux dependencies unavailable from the binary cache.

Run commands from the repository root on the corresponding host.

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
