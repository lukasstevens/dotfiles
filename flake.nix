{
  description = "Multi-machine NixOS and macOS setup";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    nix-packages = {
      url = "github:lukasstevens/nix-packages";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.nixpkgs-unstable.follows = "nixpkgs-unstable";
    };

    agent-sandbox = {
      url = "github:archie-judd/agent-sandbox.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

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

    meridian.url = "github:rynfar/meridian";

    base16.url = "github:SenchoPens/base16.nix";

    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ { nixpkgs, nixpkgs-unstable, home-manager, nix-darwin, nix-rosetta-builder, ... }:
    let
      username = "lukas";
      meridianEndpoint = import ./home/modules/meridian/endpoint.nix;

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
            inherit (inputs) base16 firefox-addons meridian;
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
              nixpkgs.overlays = [ unstableOverlay inputs.nix-packages.overlays.default linuxOverlay ];
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
              nixpkgs.overlays = [ unstableOverlay inputs.nix-packages.overlays.default ];
              networking.hostName = hostname;
            }
            nix-rosetta-builder.darwinModules.default
            home-manager.darwinModules.home-manager
            (mkHomeManager { inherit hostname extraHomeConfigurations; })
          ] ++ extraConfigurations;
        };
    in {
      devShells = nixpkgs.lib.genAttrs
        [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ]
        (system:
          let
            pkgs = import nixpkgs {
              inherit system;
              overlays = [ inputs.nix-packages.overlays.default ];
            };
            sbx = inputs.agent-sandbox.lib.${system};
            piAgentDir = "$HOME/.local/state/pi/dotfiles";
            piMeridianModels = "$HOME/.config/pi/meridian-models.json";
            pi-sandboxed = sbx.mkSandbox {
              pkg = pkgs.pi.withExtensions (extensions: [ extensions.subagents ]);
              binName = "pi";
              outName = "pi-sandboxed";
              allowedPackages = sbx.commonTools;
              allowNix = true;
              # Subagents use UNIX sockets for local process communication.
              allowUnixSockets = true;
              allowedHostPorts = [ meridianEndpoint.port ];
              roFiles = [ "${piMeridianModels}" ];
              allowedDomains = {
                "*" = "*";
              };
              rwDirs = [
                "${piAgentDir}"
                "$HOME/src/github.com/lukasstevens/nix-packages"
              ];
              # Separate state avoids inheriting the global MCP configuration.
              env = {
                PI_CODING_AGENT_DIR = "${piAgentDir}";
                # Copy via the terminal without granting host pasteboard access.
                PI_CLIPBOARD_OSC52 = "1";
                ANTHROPIC_API_KEY = "\${ANTHROPIC_API_KEY:-}";
                OPENAI_API_KEY = "\${OPENAI_API_KEY:-}";
                GEMINI_API_KEY = "\${GEMINI_API_KEY:-}";
              };
            };
          in {
            default = pkgs.mkShell {
              packages = [ pi-sandboxed ];
              shellHook = ''
                mkdir -p "${piAgentDir}"
                if [ ! -e "${piAgentDir}/models.json" ] && [ ! -L "${piAgentDir}/models.json" ]; then
                  ln -s "${piMeridianModels}" "${piAgentDir}/models.json"
                fi
              '';
            };
          });

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
        extraConfigurations = [ ./system/darwin/configuration.nix ];
        extraHomeConfigurations = [ ./home/darwin.nix ./home/devices/mac.nix ];
      };
    };
}
