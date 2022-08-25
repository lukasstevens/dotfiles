# Link this file to ~/.config/nixpkgs/home.nix to use it with home-manager

{ config, pkgs, ... }:

let
  configHome = ~/dotfiles/home;

  pkgs-unstable = import <nixos-unstable> {
    overlays = [ 
      # (self: super: { 
      #   isabelle = super.callPackage ../nix/isabelle {
      #     polyml = super.polyml.overrideAttrs (_: {
      #       pname = "polyml-for-isabelle";
      #       version = "2021-1";
      #       configureFlags = [ "--enable-intinf-as-int" "--with-gmp" "--disable-shared" ];
      #       buildFlags = [ "compiler" ];
      #       src = super.fetchFromGitHub {
      #         owner = "polyml";
      #         repo = "polyml";
      #         rev = "39d96a2def903ed019c6855e3b688df5070d633a";
      #         sha256 = "sha256-S7d2Vr/nB+rCX9d4qQj4f7edVZKocKIjc5rrx9A/B4Q=";
      #       };
      #     });
      #     z3 = super.z3_4_4_0.overrideAttrs (old: rec {
      #       src = super.fetchFromGitHub {
      #         owner  = "Z3Prover";
      #         repo   = "z3";
      #         rev    = "0482e7fe727c75e259ac55a932b28cf1842c530e";
      #         sha256 = "1m53avlljxqd2p8w266ksmjywjycsd23h224yn786qsnf36dr63x";
      #       };
      #     });
      #     java = super.openjdk17;
      #     naproche = super.naproche.overrideAttrs (_: {
      #       prePatch = ''
      #         cat >as.patch <<EOF
      #           diff --git a/src/SAD/Core/Rewrite.hs b/src/SAD/Core/Rewrite.hs
      #           index 04463ae..675a2ce 100644
      #           --- a/src/SAD/Core/Rewrite.hs
      #           +++ b/src/SAD/Core/Rewrite.hs
      #           @@ -133,7 +133,7 @@ generateConditions pos verbositySetting rules w l r =
      #              where
      #                -- check for matching normalforms and output the paths to them
      #                simpPaths leftNormalForms rightNormalForms = do
      #           -      leftPath@ ((simplifiedLeft , _):_) <- leftNormalForms
      #           +      leftPath@((simplifiedLeft , _):_) <- leftNormalForms
      #                  rightPath@((simplifiedRight, _):_) <- rightNormalForms
      #                  guard (twins simplifiedLeft simplifiedRight)
      #                  return (reverse leftPath, reverse rightPath)
      #         EOF
      #         hpack
      #         '';
      #       patches = [ "./as.patch" ];
      #     });

      #     inherit (super) veriT vampire eprover-ho isabelle-components isabelle;

      #   };
      # })
    ];
  };
  nur = import (builtins.fetchTarball {
      name = "nur";
      url = https://github.com/nix-community/NUR/archive/2a531b3ae63276d9054f861f71b7f66c95c2b0ec.tar.gz;
      sha256 = "1y7kv0x9wzzhvqpvf2f2wn4hlqlvizjfd1c9d49ngnr6pnv0jfp1";
    }) { pkgs = pkgs; };

  colors = {
    base00 = "262528"; # Default Background
    base01 = "272935"; # Lighter Background
    base02 = "3a4055"; # Selection Background
    base03 = "5a647e"; # Comments, Invisibles, Line Highlighting
    base04 = "d4cfc9"; # Dark Foreground (used for status bars)
    base05 = "e6e1dc"; # Default Foreground, Caret, Delimiters, Operators
    base06 = "f4f1ed"; # Light Foreground
    base07 = "f9f7f3"; # Light Foreground
    base08 = "de3e2f"; # Variables, XML Tags, Markup Link Text, Markup Lists, Diff Deleted
    base09 = "59abe3"; # Integers, Booleans, Constants, XML Attributes, Markup Link URL
    base0A = "f89406"; # Classes, Markup Bold, Search Text Background
    base0B = "6fd952"; # Strings, Inherited Class, Markup Code, Diff Inserted
    base0C = "1BBC9B"; # Support, Regex, Escape Characters, Markup Quotes
    base0D = "4183d7"; # Functions, Methods, Attribute IDs, Headings
    base0E = "b24edd"; # Keywords, Storage, Selector, Markup, Italic, Diff Changed
    base0F = "bc9458"; # Deprecated, Opening/Closing Embedded Language Tags
  };

  my-base16-theme = pkgs.callPackage ../nix/my-base16-theme {
    colors = colors;
    base16-shell-template = pkgs.callPackage ../nix/base16-shell-template {};
    base16-vim-template = pkgs.callPackage ../nix/base16-vim-template {};
  };

  rpiplay = pkgs.callPackage ../nix/rpiplay {};

in {
  programs.home-manager = {
    enable = true;
    path = "https://github.com/nix-community/home-manager/archive/release-22.05.tar.gz";
  };
  home.stateVersion = "21.11";
  home.username = "lukas";
  home.homeDirectory = /home/lukas;

  home.packages = with pkgs; [
    # Desktop programs
    evince
    gnome3.gnome-terminal
    pkgs-unstable.isabelle
    # isabelle-devel
    pkgs-unstable.keepassxc
    lean
    pkgs-unstable.nextcloud-client
    signal-desktop
    pkgs-unstable.tdesktop
    thunderbird

    # Developer utilities
    cmake
    ruby
    rustup
    stack
    texlive.combined.scheme-full

    # Command line utilities
    acpi
    ffmpeg-full
    rename
    rpiplay
    thefuck
    tree
    youtube-dl
    gnupg

    # Window manager
    glibcLocales
    grim
    hicolor-icon-theme
    playerctl
    slurp
    swaylock
    swayidle
    wl-clipboard
    mako
    wofi 
    qt5.qtwayland

    # Fonts
    fira
    fira-code
    font-awesome
    inconsolata
    league-of-moveable-type
    lmodern
    lmmath
    powerline-fonts
  ];

  nixpkgs.overlays = [
    (self: super: {
      waybar = super.waybar.override { pulseSupport = true; };
    })
    (self: super: {
      signal-desktop = super.signal-desktop.overrideAttrs (old: rec {
        version = "5.25.0";
        src = super.fetchurl {
          url = "https://updates.signal.org/desktop/apt/pool/main/s/signal-desktop/signal-desktop_${version}_amd64.deb";
          sha256 = "0ql9rzxrisqms3plcrmf3fjinpxba10asmpsxvhn0zlfajy47d0a";
        };
      });
    })
  ];

  fonts.fontconfig.enable = true;

  home.sessionPath = [ "~/.local/bin" "~/.cargo/bin" ];

  home.sessionVariables = {
    TERMINAL = "alacritty";
    EDITOR = "nvim";
    LOCALE_ARCHIVE_2_27 = "${pkgs.glibcLocales}/lib/locale/locale-archive";
  };

  xdg = {
    enable = true;
    configFile."nvim/colors/my-base16.vim".source = "${my-base16-theme}/share/my-base16.vim";
    mime.enable = true;
    mimeApps = {
      enable = true;
      defaultApplications = {
        "x-scheme-handler/http" = [ "firefox.desktop" ];
        "x-scheme-handler/https" = [ "firefox.desktop" ];
        "x-scheme-handler/mailto" = [ "thunderbird.desktop" ];
        "application/pdf" = [ "org.gnome.Evince.desktop" ];
        "image/jpeg" = [ "org.gnome.eog.desktop" ];
        "image/png" = [ "org.gnome.eog.desktop" ];
        "image/tiff" = [ "org.gnome.eog.desktop" ];
        "image/bmp" = [ "org.gnome.eog.desktop" ];
        "image/gif" = [ "org.gnome.eog.desktop" ];
      };
    };
  };

  home.file = {
    ".latexmkrc".text = "$pdf_previewer = 'start evince';\n";
    ".XCompose".source = "${configHome}/XCompose";
    ".vscode/argv.json".text = ''
      { "enable-crash-reporter": false }
    '';
  };

  services.network-manager-applet.enable = true;

  services.nextcloud-client = {
    enable = true;
    package = pkgs-unstable.nextcloud-client;
  };

  services.kdeconnect.enable = true;

  gtk = {
    enable = true;
    font = {
      name = "DejaVu Sans 11";
      package = pkgs.dejavu_fonts;
    };
    iconTheme = {
      name = "Adwaita";
      package = pkgs.gnome3.adwaita-icon-theme;
    };
    theme = {
      name = "Arc-Dark";
      package = pkgs.arc-theme;
    };
  };

  qt = {
    enable = true;
    platformTheme = "gtk";
  };

  wayland.windowManager.sway = {
    enable = true;
    xwayland = true;
    wrapperFeatures.gtk = true;
    extraSessionCommands = ''
      export SDL_VIDEODRIVER=wayland
      export QT_QPA_PLATFORM=wayland
      export QT_WAYLAND_DISABLE_WINDOWDECORATION=1
      export _JAVA_AWT_WM_NONREPARENTING=1
      export MOZ_ENABLE_WAYLAND=1
      export XDG_SESSION_TYPE=wayland
      export XDG_CURRENT_DESKTOP=sway
      '';
    config = import (configHome + /sway/settings.nix) pkgs;
  };

  programs.waybar = {
    enable = true;
    settings = import (configHome + /sway/waybar-settings.nix) pkgs;
  };

  programs.alacritty = {
    enable = true;
    settings = import (configHome + /alacritty-settings.nix);
  };

  programs.firefox = {
    enable = true;
    package = pkgs.firefox-wayland;
    extensions = with nur.repos.rycee.firefox-addons; [
      i-dont-care-about-cookies
      ublock-origin
      umatrix
      keepassxc-browser
    ];
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.git = {
    enable = true;
    userName = "Lukas Stevens";
    userEmail = "mail@lukas-stevens.de";
    extraConfig = {
      pull.rebase = true;
    };
  };

  programs.mercurial = {
    enable = true;
    userName = "Lukas Stevens";
    userEmail = "mail@lukas-stevens.de";
    extraConfig = {
      extensions = {
        rebase = "";
        strip = "";
        evolve = "${pkgs.python38Packages.hg-evolve}/lib/python3.8/site-packages/hgext3rd/evolve/__init__.py";
      topic = "${pkgs.python38Packages.hg-evolve}/lib/python3.8/site-packages/hgext3rd/topic/__init__.py";
      };
    };
  };

  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
    withPython3 = true;
    withRuby = true;
    extraConfig = builtins.readFile (configHome + /vimrc);
    plugins =
      let
        cyp-syntax = pkgs.vimUtils.buildVimPlugin {
          pname = "cyp-syntax";
          version = "2019-11-30";
          src = pkgs.fetchFromGitHub {
            owner = "HE7086";
            repo = "cyp-vim-syntax";
            rev = "a13fc823a490fca1150d36d449594ce0e0a33a79";
            sha256 = "1wadkvn4vkck9c11r2s33747qx3p1iwzrxfxzlchlw0vc5spr2f7";
          };
        };
      in
        with pkgs.vimPlugins; [
          awesome-vim-colorschemes
          vim-nix
          nerdtree
          rust-vim
          command-t
          deoplete-nvim
          ale
          { plugin = vimtex; config = "let g:tex_flavor = 'latex'"; }
          haskell-vim
          cyp-syntax
        ];
  };

  programs.ssh = {
    enable = true;
    extraConfig = "AddKeysToAgent yes";
  };

  programs.keychain = {
    enable = true;
    enableZshIntegration = true;
    agents = [ "gpg" "ssh" ];
    keys = [ "id_ed25519" ];
    extraFlags = [ "--quiet" "--noask" "--timeout 20" ];
  };

  programs.vscode = {
    enable = true;
    package = pkgs.vscodium;
    userSettings = {
      "telemetry.enableTelemetry" = false;
      "update.mode" = "manual";
      #"isabelle.home" = "${isabelle-devel}";
      "haskell.indentationRules.enabled" = false;
      "haskell.trace.server" = "messages";
      "editor.fontFamily" = "Inconsolata for Powerline, monospace";
      "extensions.autoUpdate" = false;
      "window.zoomLevel" = 1;
    };
    keybindings = [
      { key = "ctrl+`"; command = "terminal.focus"; }
      { key = "ctrl+`"; command = "workbench.action.focusActiveEditorGroup"; when = "terminalFocus"; }
      { key = "ctrl+h"; command = "workbench.action.navigateLeft"; }
      { key = "ctrl+l"; command = "workbench.action.navigateRight"; }
      { key = "ctrl+j"; command = "workbench.action.navigateDown"; }
      { key = "ctrl+k"; command = "workbench.action.navigateUp"; }
    ];
    extensions =
      let
        cyp = pkgs-unstable.vscode-utils.buildVscodeMarketplaceExtension {
          mktplcRef = {
            name = "vscode-cyp";
            publisher = "jonhue";
            version = "1.1.0";
            sha256 = "19pyn7l6hjl4mrvqfd137mi06k33glb7xiq37kkqannzhbh7did3";
          };
        };
      in with pkgs-unstable.vscode-extensions; [
        cyp
        justusadam.language-haskell
        vscodevim.vim
        matklad.rust-analyzer
        arrterian.nix-env-selector 
      ];
  };

  programs.zsh = import (configHome + /zsh-settings.nix) { inherit my-base16-theme; };
}

