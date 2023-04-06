# Link this file to ~/.config/nixpkgs/home.nix to use it with home-manager

{ config, pkgs, lib, ... }:

let
  configHome = ~/dotfiles/home;

  pkgs-unstable = import <nixos-unstable> {
    overlays = [ 
    ];
  };
  nur = import (builtins.fetchTarball {
      name = "nur";
      url = https://github.com/nix-community/NUR/archive/854a244d72792711cd05ecbe35bccfd93bf33ab3.tar.gz;
      sha256 = "08j6gbacilnwr50qskn4jw9pml3jm2sxl0jj3n8fdxiapxf5pps9";
    }) { pkgs = pkgs; };

  rpiplay = pkgs.callPackage ../nix/rpiplay {};

in {
  imports = [
    (builtins.getFlake "github:SenchoPens/base16.nix").homeManagerModule
  ];

  programs.home-manager = {
    enable = true;
    path = "https://github.com/nix-community/home-manager/archive/release-22.11.tar.gz";
  };
  home.stateVersion = "21.11";
  home.username = "lukas";
  home.homeDirectory = /home/lukas;

  home.packages = with pkgs; [
    # Desktop programs
    evince
    gnome3.gnome-terminal
    pkgs-unstable.isabelle
    pkgs-unstable.keepassxc
    lean
    nextcloud-client
    # signal-desktop
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

  nix = {
    package = pkgs.nix;
    settings = {
      experimental-features = [ "flakes" "nix-command" ];
    };
  };

  fonts.fontconfig.enable = true;

  home.sessionPath = [ "~/.local/bin" "~/.cargo/bin" ];

  home.sessionVariables = {
    TERMINAL = "alacritty";
    EDITOR = "nvim";
    LOCALE_ARCHIVE_2_27 = "${pkgs.glibcLocales}/lib/locale/locale-archive";
  };

  xdg = {
    enable = true;
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

  scheme =
    let
      base16-themes = builtins.fetchTarball {
        name = "base16-themes";
        url = https://github.com/tinted-theming/base16-schemes/archive/42d74711418db38b08575336fc03f30bd3799d1d.tar.gz;
        sha256 = "0dpjqv18kkdcv3c1fjky3ik9c08plf421gjn4861hvabvbsaaav5";
      };
    in #base16-themes + "/onedark.yaml";
    {
      slug = "lks-dark";
      scheme = "Dark Theme by Lukas Stevens";
      author = "Lukas Stevens";

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


  # Manually configure nm-applet to start after sway and use --indicator
  systemd.user.services.network-manager-applet = {
    Unit = {
      Description = "Network Manager applet";
      Requires = [ "tray.target" ];
      After = [ "sway-session.target" "tray.target" ];
    };

    Install = { WantedBy = [ "sway-session.target" ]; };

    Service = {
      ExecStart = "${pkgs.networkmanagerapplet}/bin/nm-applet --sm-disable --indicator";
    };
  };

  # Manually configure nextcloud-client to start after sway
  systemd.user.services.nextcloud-client = {
    Unit = {
      Description = "Nextcloud Client";
      After = [ "sway-session.target" ];
    };

    Service = {
      Environment = "PATH=${config.home.profileDirectory}/bin";
      ExecStart = "${pkgs.nextcloud-client}/bin/nextcloud";
    };

    Install = { WantedBy = [ "sway-session.target" ]; };
  };

  services.kdeconnect = {
    enable = true;
    indicator = true;
  };

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
    systemdIntegration = true;
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
      config = import (configHome + /sway/settings.nix) { inherit pkgs lib config; };
  };

  programs.waybar = {
    enable = true;
    settings = import (configHome + /sway/waybar-settings.nix) pkgs;
  };

  services.swayidle = {
    enable = true;
    events = [ 
      { event = "before-sleep"; command = "loginctl lock-session"; }
      { event = "lock"; command = "${pkgs.swaylock}/bin/swaylock --color ${config.scheme.base00}"; }
    ];
  };

  programs.alacritty = {
    enable = true;
    settings = import (configHome + /alacritty-settings.nix);
  };

  programs.firefox = {
    enable = true;
    package = pkgs.firefox-wayland;
    extensions = with nur.repos.rycee.firefox-addons; [
      consent-o-matic
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

  xdg.configFile."nvim/colors/base16-scheme.vim".source = (config.scheme {
    templateRepo = builtins.fetchTarball {
      name = "base16-vim";
      url = https://github.com/tinted-theming/base16-vim/archive/79d4fb4575b6e9fab785c44557529240c0b7093a.tar.gz;
      sha256 = "15qkn0gkcshzi9lvm70ycx7flikc3c4g2c7sdyk0nvjxmiifxxvm";
    };
  });

  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
    withPython3 = true;
    withRuby = true;
    extraConfig = builtins.readFile (configHome + /vimrc) + ''
      let base16colorspace=256
      try
          colorscheme base16-scheme
      catch
          echom "colorscheme base16-scheme not found."
      endtry
      '';
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

          vim-nix
          nerdtree
          rust-vim
          { plugin = command-t; config = "let g:CommandTPreferredImplementation = 'lua'"; }
          deoplete-nvim
          ale
          {
            plugin = vimtex;
            config = ''
              let g:tex_flavor = 'latex'
              let g:maplocalleader = '<'
              '';
          }
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
        haskell.haskell
        vscodevim.vim
        matklad.rust-analyzer
        arrterian.nix-env-selector 
      ];
  };

  programs.zsh = import (configHome + /zsh-settings.nix) { inherit config; };
}

