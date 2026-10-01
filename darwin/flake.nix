{
  description = "Lukas's darwin system";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-25.11-darwin";
    # nixpkgs-unstable.url = "github.com/NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/nix-darwin-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    #nur = {
    #  url = "github.com/nix-community/NUR";
    #  inputs.nixpkgs.follows = "nixpkgs-unstable";
    #};
    nix-rosetta-builder = {
      url = "github:cpick/nix-rosetta-builder";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs, nix-rosetta-builder, ... }: {
    darwinConfigurations."Lukass-MacBook-Pro" = nix-darwin.lib.darwinSystem {
      modules = [
        ./configuration.nix
        nix-rosetta-builder.darwinModules.default
      ];
      specialArgs = { inherit inputs; };
    };
  };
}
