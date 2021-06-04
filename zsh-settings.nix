{ my-base16-theme }:

{
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
      oh-my-zsh-plugin = name: { name = "plugins/${name}"; tags = [ "from:oh-my-zsh" ]; };
      oh-my-zsh-plugins = names: builtins.map oh-my-zsh-plugin names;
    in {
      enable = true;
      plugins = [
        { name = "romkatv/powerlevel10k"; tags = [ "as:theme" ]; }
        { name = "jdxcode/gh"; tags = [ "as:plugin" "use:zsh/gh/gh.plugin.zsh" ]; }
        { name = "jdxcode/gh"; tags = [ "as:command" "use:zsh/gh/_gh" ]; }
      ] ++ oh-my-zsh-plugins [
        "cargo" "git-extras" "npm" "pip" "pyenv" "python" "stack" "thefuck" "wd"
      ];
    };

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
    source ${my-base16-theme}/share/my-base16.sh

    # Go up directories
    ..(){
      cd ../$@
    }
    ..2(){
      cd ../../$@
    }
    '';
}
