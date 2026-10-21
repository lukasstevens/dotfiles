{ config, pkgs, lib, base16, firefox-addons, ... }:

let
  desktopPkgs = if pkgs.stdenv.hostPlatform.isLinux then pkgs.unstable else pkgs;
in
{
  imports = [
    base16.homeManagerModule
    ./modules/alacritty
    ./modules/isabelle
    ./modules/meridian
    ./modules/pi
    ./modules/vim
    ./modules/zsh
  ];

  home.packages = with pkgs; [
    rename
    tree
    yt-dlp

    dmtx-utils
    imagemagick
    texlive.combined.scheme-full

    # Desktop applications supported on both Linux and macOS.
    desktopPkgs.keepassxc
    desktopPkgs.signal-desktop
    desktopPkgs.telegram-desktop
    thunderbird

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

  nix = {
    settings = {
      experimental-features = [ "flakes" "nix-command" ];
    };
  };

  home.sessionPath = [
    "~/.local/bin"
    "~/.cargo/bin"
  ];

  home.sessionVariables = {
    TERMINAL = "alacritty";
    EDITOR = "nvim";
  };

  xdg.enable = true;

  home.file = {
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

  programs.firefox = {
    enable = true;
    package = pkgs.firefox;
    profiles."lukas" = {
      id = 0;
      isDefault = true;
      extensions.packages = with firefox-addons.packages.${pkgs.stdenv.hostPlatform.system}; [
        consent-o-matic
        ublock-origin
        umatrix
        keepassxc-browser
      ];
    };
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "Lukas Stevens";
        email = "mail@lukas-stevens.de";
      };
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
      };
    };
  };

  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    settings."*" = {
      forwardAgent = false;
      addKeysToAgent = "yes";
      compression = false;
      serverAliveInterval = 0;
      serverAliveCountMax = 3;
      hashKnownHosts = false;
      userKnownHostsFile = "~/.ssh/known_hosts";
      controlMaster = "no";
      controlPath = "~/.ssh/master-%r@%n:%p";
      controlPersist = "no";
    };
  };

  programs.keychain = {
    enable = true;
    enableZshIntegration = true;
    keys = [ "id_ed25519" "id_ecdsa" ];
    extraFlags =[ "--quiet" "--noask" "--timeout 20" ];
  };

  programs.vscodium = {
    enable = true;
    profiles.default = {
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
      extensions = with pkgs.unstable.vscode-extensions; [
        arrterian.nix-env-selector 
        kamikillerto.vscode-colorize
        vscodevim.vim

        justusadam.language-haskell
        haskell.haskell

        rust-lang.rust-analyzer
      ];
    };
  };
}

