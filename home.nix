# Link this file to ~/.config/nixpkgs/home.nix to use it with home-manager

{ config, pkgs
, ... }:

let
  configHome = ~/dotfiles;

  i3blocks-contrib = pkgs.callPackage "${configHome}/nix/i3blocks-contrib" {};
  pkgs-master = import (builtins.fetchTarball {
        name = "nixpkgs-master";
        url = https://github.com/NixOS/nixpkgs/archive/a31736120c5de6e632f5a0ba1ed34e53fc1c1b00.tar.gz;
        # Hash obtained using `nix-prefetch-url --unpack <url>`
        sha256 = "0xfjizw6w84w1fj47hxzw2vwgjlszzmsjb8k8cgqhb379vmkxjfl";
      }) {};
  polyml = pkgs.callPackage "${configHome}/nix/polyml" {};
  isabelle-2020 = pkgs.callPackage "${configHome}/nix/isabelle" {
    polyml = polyml; java = pkgs.openjdk11; nettools = pkgs.nettools; z3 = pkgs.z3;
  };
in {

  home.packages =
    [
      # Desktop programs
      pkgs.alacritty
      pkgs.evince
      pkgs.firefox
      pkgs.gnome3.gnome-terminal
      isabelle-2020
      pkgs.jetbrains.idea-community
      pkgs.keepassxc
      pkgs.lean
      pkgs.nextcloud-client
      pkgs-master.signal-desktop
      pkgs-master.tdesktop
      pkgs.thunderbird

      # Developer utilities
      pkgs.cmake
      pkgs.ruby
      pkgs.rustup
      pkgs.texlive.combined.scheme-full

      # Command line utilities
      pkgs.acpi
      pkgs.ffmpeg-full
      pkgs.rename
      pkgs.thefuck
      pkgs.tree
      pkgs.xclip
      pkgs.xorg.xprop
      pkgs.youtube-dl
      pkgs.gnupg

      # Window manager
      pkgs.base16-builder
      pkgs.gnome3.networkmanagerapplet
      pkgs.hicolor-icon-theme
      pkgs.i3
      pkgs.i3lock
      pkgs.i3blocks
      pkgs.rofi
      pkgs.glibcLocales

      # Fonts
      pkgs.fira
      pkgs.fira-code
      pkgs.inconsolata
      pkgs.powerline-fonts
      pkgs.lmodern
      pkgs.lmmath
    ];

    fonts.fontconfig.enable = true;

    home.sessionVariables = {
      TERMINAL = "alacritty";
      EDITOR = "nvim";
      LOCALE_ARCHIVE_2_27 = "${pkgs.glibcLocales}/lib/locale/locale-archive";
    };

    home.keyboard = {
      layout = "us";
      options = [ "compose:caps" ];
    };
    
    xdg = {
      enable = true;
      configFile."i3/i3blocks".text = ''
        command=${i3blocks-contrib}/libexec/i3blocks/$BLOCK_NAME
        '' + builtins.readFile (configHome + /i3/i3blocks);
      configFile."alacritty/alacritty.yml".source = "${configHome}/alacritty.yml";
      configFile."nvim/colors/my-base16.vim".source = "${configHome}/colors/my-base16.vim";
      configFile."mimeapps.list".text=''
      [Default Applications]
      application/pdf=org.gnome.Evince.desktop;
      '';
    };

    xresources.extraConfig = (builtins.readFile (configHome + /Xresources));

    home.file = {
      ".profile".source = "${configHome}/profile";
      ".zprofile".source = "${configHome}/zprofile";
      ".bashrc".source = "${configHome}/bashrc";
      ".latexmkrc".text = "$pdf_previewer = 'start evince';\n";
      ".XCompose".source = "${configHome}/XCompose";
    };

    services.network-manager-applet.enable = true;

    services.nextcloud-client.enable = true;

    services.gpg-agent.enable = true;

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

    xsession = {
      enable = true;
      windowManager.i3 = {
        enable = true;
        extraConfig = (builtins.readFile (configHome + /i3/config));
        config = null;
      };
    };

    programs.neovim = {
      enable = true;
      package = pkgs-master.neovim;
      viAlias = true;
      vimAlias = true;
      vimdiffAlias = true;
      withPython3 = true;
      withRuby = true;
      configure = {
          customRC = (builtins.readFile (configHome + /vimrc));

           plug.plugins = with pkgs.vimPlugins; [
                vim-nix
                nerdtree
                rust-vim
                command-t
                deoplete-nvim
                ale
                vimtex
                haskell-vim
           ];

      };
    };

    programs.zsh = {
      enable = true;
      enableCompletion = true;
      sessionVariables = {
        ANTIGEN_DIR = "${pkgs.antigen}/share/antigen/";
      }; 
      initExtra = (builtins.readFile (configHome + /zshrc));
    };

    programs.fzf = {
      enable = true;
      enableZshIntegration = true;
    };

    programs.git = {
      enable = true;
      userName = "Lukas Stevens";
      userEmail = "mail@lukas-stevens.de";
    };

    programs.mercurial = {
      enable = true;
      userName = "Lukas Stevens";
      userEmail = "mail@lukas-stevens.de";
    };

    programs.home-manager = {
      enable = true;
      path = "https://github.com/rycee/home-manager/archive/release-20.03.tar.gz";
    };

    nixpkgs.config.allowUnfree = true;

    imports =
      let
        fix-vsliveshare = fetchTarball {
          url = "https://github.com/msteen/nixos-vsliveshare/tarball/a54bfc74c5e7ae056f61abdb970c6cd6e8fb5e53";
          sha256 = "0rvgp2k5fh1drmm8908ghzaz295b1q1ccw172850phn3chkw5kpx";
        };
      in [ "${fix-vsliveshare}/modules/vsliveshare/home.nix" ];

    services.vsliveshare = {
      enable = true;
      extensionsDir = "$HOME/.vscode/extensions";
    };

    programs.vscode = {
      enable = true;
      userSettings = {
        "telemetry.enableCrashReporter" = false;
        "telemetry.enableTelemetry" = false;
        "update.mode" = "manual";
        #"isabelle.home" = "${isabelle-devel}";
        "haskell.indentationRules.enabled" = false;
        "haskell.trace.server" = "messages";
      };
      extensions = [
        pkgs.vscode-extensions.justusadam.language-haskell
        pkgs.vscode-extensions.vscodevim.vim
      ];
    };

  }


