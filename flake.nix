{
  description = "Multi-machine NixOS setup";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    base16 = {
      url = "github:SenchoPens/base16.nix";
    };

    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ { self, nixpkgs, nixpkgs-unstable, home-manager, ... }:
    let
      username = "lukas";
      
      mkHost = {
        system,
        hostname,
        extraConfigurations,
        extraHomeConfigurations,
      }:
        nixpkgs.lib.nixosSystem {
          inherit system;

          specialArgs = {
            inherit username hostname;
          };

          modules = [
            {
              nixpkgs.overlays = [
                (final: prev: {
                  unstable = import nixpkgs-unstable {
                    inherit system;
                  };
                })
                (self: super: {
                  fcitx-engines = super.fcitx5;
                  waybar = super.waybar.override { pulseSupport = true; };
                  rofi = super.rofi.override {
                    plugins = [ super.rofi-emoji ];
                  };
                })
              ];
            }

           ./system/configuration.nix 

            home-manager.nixosModules.home-manager
          ] ++
          extraConfigurations ++
          [
            {
              networking.hostName = hostname;

              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;

                backupFileExtension = "bak";

                extraSpecialArgs = {
                  inherit nixpkgs username hostname;
                  inherit (inputs) base16 firefox-addons;
                };

                users."lukas" = {
                  imports = [ ./home/common.nix ] ++ extraHomeConfigurations;
                };
              };
            }
          ];
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

        # TODO: add darwin
      };
    };
} 
