{ config, pkgs, lib, base16, firefox-addons, ... }:

{
  imports = [
    base16.homeManagerModule
  ];

  home.packages = with pkgs; [
    rename
    tree
    yt-dlp

    haskell.compiler.ghc9122
    (haskell-language-server.override { supportedGhcVersions = [ "9122" ]; })
    stack

    dmtx-utils
    imagemagick
    texlive.combined.scheme-full

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

  fonts.fontconfig = {
    enable = true;
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
    ".latexmkrc".text = "$pdf_previewer = 'start evince';\n";
    ".XCompose".source = ./XCompose;
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

  programs.alacritty = {
    enable = true;
    settings = import ./alacritty-settings.nix { inherit pkgs lib; };
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
    extraConfig = builtins.readFile ./vimrc + ''
      let base16colorspace=256
      try
          colorscheme base16-scheme
      catch
          echom "colorscheme base16-scheme not found."
      endtry
      '';
    plugins = with pkgs.vimPlugins; [
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
    ];
  };

  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    matchBlocks."*" = {
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

  programs.vscode = {
    enable = true;
    package = pkgs.vscodium;
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

  programs.zsh = import ./zsh-settings.nix { inherit config lib; };
}

