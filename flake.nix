{
  description = "Multi-machine NixOS and macOS setup";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/nix-darwin-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-rosetta-builder = {
      url = "github:cpick/nix-rosetta-builder";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    base16.url = "github:SenchoPens/base16.nix";

    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ { nixpkgs, nixpkgs-unstable, home-manager, nix-darwin, nix-rosetta-builder, ... }:
    let
      username = "lukas";

      # Available to both system modules and Home Manager via useGlobalPkgs.
      unstableOverlay = final: prev: {
        unstable = import nixpkgs-unstable {
          system = final.stdenv.hostPlatform.system;
        };
      };

      linuxOverlay = final: prev: {
        fcitx-engines = prev.fcitx5;
        waybar = prev.waybar.override { pulseSupport = true; };
        rofi = prev.rofi.override {
          plugins = [ prev.rofi-emoji ];
        };
      };

      mkHomeManager = { hostname, extraHomeConfigurations }: {
        home-manager = {
          useGlobalPkgs = true;
          useUserPackages = true;
          backupFileExtension = "bak";
          extraSpecialArgs = {
            inherit nixpkgs username hostname;
            inherit (inputs) base16 firefox-addons;
          };
          users.${username} = {
            home.username = username;
            imports = [ ./home/common.nix ] ++ extraHomeConfigurations;
          };
        };
      };

      mkHost = { system, hostname, extraConfigurations, extraHomeConfigurations }:
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit username hostname; };
          modules = [
            {
              nixpkgs.overlays = [ unstableOverlay linuxOverlay ];
              networking.hostName = hostname;
            }
            ./system/configuration.nix
            home-manager.nixosModules.home-manager
            (mkHomeManager { inherit hostname extraHomeConfigurations; })
          ] ++ extraConfigurations;
        };

      mkDarwinHost = { system, hostname, extraConfigurations, extraHomeConfigurations }:
        nix-darwin.lib.darwinSystem {
          specialArgs = { inherit inputs username hostname; };
          modules = [
            {
              nixpkgs.hostPlatform = system;
              nixpkgs.overlays = [ unstableOverlay ];
              networking.hostName = hostname;
            }
            ./darwin/configuration.nix
            nix-rosetta-builder.darwinModules.default
            home-manager.darwinModules.home-manager
            (mkHomeManager { inherit hostname extraHomeConfigurations; })
          ] ++ extraConfigurations;
        };
    in {
      nixosConfigurations = {
        nixps = mkHost {
          system = "x86_64-linux";
          hostname = "nixps";
          extraConfigurations = [ ./system/nixps/configuration.nix ];
          extraHomeConfigurations = [ ./home/linux.nix ./home/devices/nixps.nix ];
        };

        nixtop = mkHost {
          system = "x86_64-linux";
          hostname = "nixtop";
          extraConfigurations = [ ./system/nixtop/configuration.nix ];
          extraHomeConfigurations = [ ./home/linux.nix ./home/devices/nixtop.nix ];
        };
      };

      darwinConfigurations."Lukass-MacBook-Pro" = mkDarwinHost {
        system = "aarch64-darwin";
        hostname = "Lukass-MacBook-Pro";
        extraConfigurations = [];
        extraHomeConfigurations = [ ./home/darwin.nix ./home/devices/mac.nix ];
      };
    };
}
