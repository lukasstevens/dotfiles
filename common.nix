# Link this file to ~/.config/nixpkgs/home.nix to use it with home-manager

{ config, pkgs
, ... }:

let
  configHome = ~/dotfiles;

  i3blocks-contrib = pkgs.callPackage "${configHome}/nix/i3blocks-contrib" {};
  pkgs-master = import (builtins.fetchTarball {
        name = "nixpkgs-master";
        url = https://github.com/NixOS/nixpkgs/archive/f74f2f354866c828248a419ef9a2cbddc793b7f9.tar.gz;
        # Hash obtained using `nix-prefetch-url --unpack <url>`
        sha256 = "1jxb2kb83mrmzg06l7c1zw9pikk2l1lpg8dl0rvni65bgmlxf7xy";
      }) {};
  # polyml = pkgs.callPackage "${configHome}/nix/polyml" {};
in {
  home.packages =
    [
      # Desktop programs
      pkgs.alacritty
      pkgs.evince
      pkgs.firefox
      pkgs.gnome3.gnome-terminal
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
      (pkgs.vimHugeX.override {
          python = pkgs.python37;
          ruby = pkgs.ruby;
      })
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

    nixpkgs.overlays = [
    ];

    home.sessionVariables = {
      TERMINAL = "alacritty";
      EDITOR = "vim";
      I3BLOCKS_SCRIPT_DIR = "${i3blocks-contrib}";
      LOCALE_ARCHIVE_2_27 = "${pkgs.glibcLocales}/lib/locale/locale-archive";
    };

    home.keyboard = {
      layout = "us";
      options = [ "compose:caps" ];
    };
    
    xdg = {
      enable = true;
      configFile."i3/i3blocks".source = "${configHome}/i3/i3blocks";
      configFile."alacritty/alacritty.yml".source = "${configHome}/alacritty.yml";
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
      ".vimrc".source = "${configHome}/vimrc";
      ".vim/colors/my-base16.vim".source = "${configHome}/colors/my-base16.vim";
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

    programs.zsh = {
      enable = true;
      enableCompletion = true;
      sessionVariables = {
        ANTIGEN_DIR = "${pkgs.antigen}/share/antigen/";
      }; 
      initExtra = (builtins.readFile (configHome + /zshrc)) + ''
        vim() {
          nix-shell -p python37Packages.pynvim --run "vim $@"
        }
      '';
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

    programs.home-manager = {
      enable = true;
      path = "https://github.com/rycee/home-manager/archive/release-20.03.tar.gz";
    };

    nixpkgs.config.allowUnfree = true;

    programs.vscode = {
      enable = true;
      userSettings = {
        "telemetry.enableCrashReporter" = false;
        "telemetry.enableTelemetry" = false;
        "update.mode" = "manual";
        #"isabelle.home" = "${isabelle-devel}";
      };
      extensions = [
      ];
    };

  }


