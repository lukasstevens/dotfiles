{ config }:

let
  base16-shell = builtins.fetchTarball {
    name = "base16-shell";
    url = https://github.com/tinted-theming/base16-shell/archive/d0737249d4c8bb26dc047ea9fba0054ae7024c04.tar.gz;
    sha256 = "1jc8anmvnrn9nw4fgmwp7w9i5naw4n4ixw82afdg9x6cyaxxr8sz";
  };
in {
  enable = true;

  enableCompletion = true;
  defaultKeymap = "emacs";

  localVariables = {
    POWERLEVEL9K_DISABLE_CONFIGURATION_WIZARD = "true";
    POWERLEVEL9K_DIR_SHORTEN_STRATEGY = "truncate_middle";
    POWERLEVEL9K_DIR_SHORTEN_LENGTH = 4;
    POWERLEVEL9K_PROMPT_ON_NEWLINE = "true";
    POWERLEVEL9K_LEFT_PROMPT_ELEMENTS = [ "context" "dir" "virtualenv" "vcs" "status" ];
    POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS = [ "command_execution_time" "time" ];
    POWERLEVEL9K_MULTILINE_FIRST_PROMPT_PREFIX = "";
    POWERLEVEL9K_MULTILINE_LAST_PROMPT_PREFIX = "%K{white} %k%F{white}\\uE0B0%f ";
    POWERLEVEL9K_PROMPT_ADD_NEWLINE = "true";
    POWERLEVEL9K_CONTEXT_ALWAYS_SHOW = "true";
    POWERLEVEL9K_CONTEXT_ROOT_FOREGROUND = "black";
    POWERLEVEL9K_CONTEXT_ROOT_BACKGROUND = "white";
    POWERLEVEL9K_CONTEXT_DEFAULT_FOREGROUND = "black";
    POWERLEVEL9K_CONTEXT_DEFAULT_BACKGROUND = "white";
    POWERLEVEL9K_STATUS_OK = "false";
    POWERLEVEL9K_COMMAND_EXECUTION_TIME_ICON = "";
  };

  zplug =
    let
      oh-my-zsh-plugin = name: { name = "plugins/${name}"; tags = [ "as:plugin" "from:oh-my-zsh" ]; };
      oh-my-zsh-plugins = names: builtins.map oh-my-zsh-plugin names;
    in {
      enable = true;
      plugins = [
        { name = "romkatv/powerlevel10k"; tags = [ "as:theme" "depth:1" ]; }
        { name = "jdxcode/gh"; tags = [ "as:plugin" "use:zsh/gh/gh.plugin.zsh" ]; }
        { name = "jdxcode/gh"; tags = [ "as:command" "use:zsh/gh/_gh" ]; }
      ] ++ oh-my-zsh-plugins [
        "docker" "git-extras" "pip" "pyenv" "stack" "thefuck" "wd"
      ];
    };

  initExtraBeforeCompInit = '' 
    zstyle ':completion:*' completer _extensions _complete _approximate 
    setopt AUTO_MENU
    zstyle ':completion:*' menu select
    '';

  shellAliases = {
    setclip = "wl-copy";
    getclip = "wl-paste";

    ls = "ls --color=auto";
    ll = "ls -l";
    la = "ls -la";
    lah = "ls -lah";
    l = "ls -CF";

    bm = "wd add";
    to = "wd";
  };

  initExtra = ''
    source ${config.scheme { templateRepo = base16-shell; }}

    # Up arrow
    bindkey '\e[A' up-line-or-history
    bindkey '\eOA' up-line-or-history

    # Down arrow
    bindkey '\e[B' down-line-or-history
    bindkey '\eOB' down-line-or-history

    # Delete key
    bindkey "^[[3~" delete-char

    # Shift-Tab
    bindkey '^[[Z' reverse-menu-complete

    # Go up directories
    ..(){
      cd ../$@
    }
    ..2(){
      cd ../../$@
    }
    '';
}
