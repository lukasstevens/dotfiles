source /usr/share/zsh-antigen/antigen.zsh &> /dev/null || source $HOME/.local/share/zsh-antigen/antigen.zsh &> /dev/null || echo "You need to install antigen first."

# Absolute path of this config
script_dir=$(dirname $(realpath ${(%):-%x}))

# Powerlevel9k settings
POWERLEVEL9K_SHORTEN_STRATEGY="truncate_middle"
POWERLEVEL9K_SHORTEN_DIR_LENGTH=4
POWERLEVEL9K_PROMPT_ON_NEWLINE=true
POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(context dir vcs status)
POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(time)
POWERLEVEL9K_MULTILINE_FIRST_PROMPT_PREFIX=''
POWERLEVEL9K_MULTILINE_LAST_PROMPT_PREFIX='%F{white} \u27A5  %f'
POWERLEVEL9K_ALWAYS_SHOW_CONTEXT=true
POWERLEVEL9K_CONTEXT_ROOT_FOREGROUND="black"
POWERLEVEL9K_CONTEXT_ROOT_BACKGROUND="white"
POWERLEVEL9K_CONTEXT_DEFAULT_FOREGROUND="black"
POWERLEVEL9K_CONTEXT_DEFAULT_BACKGROUND="white"

# Antigen plugins
antigen use oh-my-zsh

antigen theme bhilburn/powerlevel9k powerlevel9k

antigen bundle cargo
antigen bundle git-extras
antigen bundle npm
antigen bundle pip
antigen bundle python
antigen bundle thefuck
antigen bundle wd
antigen bundle dickeyxxx/gh zsh/gh

antigen apply

# User configuration

# Shell coloring
base16_shell=$script_dir/colors/my-base16.sh
[[ -s $base16_shell ]] && source $base16_shell

# Additional configuration
source $script_dir/zshrc.d/*

# End user configuration

