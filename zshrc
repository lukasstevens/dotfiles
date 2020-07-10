source "$ANTIGEN_DIR/antigen.zsh" &> /dev/null || echo "You need to install antigen first."

# Powerlevel10k settings
POWERLEVEL9K_DISABLE_CONFIGURATION_WIZARD=true
POWERLEVEL9K_DIR_SHORTEN_STRATEGY="truncate_middle"
POWERLEVEL9K_DIR_SHORTEN_LENGTH=4
POWERLEVEL9K_PROMPT_ON_NEWLINE=true
#POWERLEVEL9K_GITSTATUS_DIR=$HOME/.antigen/bundles/romkatv/gitstatus
POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(context dir virtualenv vcs status)
POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(command_execution_time time)
POWERLEVEL9K_MULTILINE_FIRST_PROMPT_PREFIX_ICON=''
POWERLEVEL9K_MULTILINE_LAST_PROMPT_PREFIX_ICON='%K{white} %k%F{white}\uE0B0%f '
POWERLEVEL9K_PROMPT_ADD_NEWLINE=true
POWERLEVEL9K_CONTEXT_ALWAYS_SHOW=true
POWERLEVEL9K_CONTEXT_ROOT_FOREGROUND="black"
POWERLEVEL9K_CONTEXT_ROOT_BACKGROUND="white"
POWERLEVEL9K_CONTEXT_DEFAULT_FOREGROUND="black"
POWERLEVEL9K_CONTEXT_DEFAULT_BACKGROUND="white"
POWERLEVEL9K_STATUS_OK=false
POWERLEVEL9K_COMMAND_EXECUTION_TIME_ICON=''

# Antigen plugins
antigen use oh-my-zsh

antigen theme romkatv/powerlevel10k 

antigen bundle cargo
antigen bundle git-extras
antigen bundle npm
antigen bundle pip
antigen bundle pyenv
antigen bundle python
antigen bundle stack
antigen bundle thefuck
antigen bundle wd

antigen bundle jdxcode/gh zsh/gh

antigen apply

# Shell coloring
source "$HOME/dotfiles/colors/my-base16.sh"

# Aliases
alias xclip='xclip -selection c'
alias setclip='xclip -selection c'
alias getclip='xclip -selection clipboard -o'

alias ll='ls -l'
alias la='ls -la'
alias lah='ls -lah'
alias l='ls -CF'

alias bm='wd add'
alias to='wd'

# go up directories
..(){
    cd ../$@
}

..2()
{
    cd ../../$@
}

# Use terminal mode for emacs
alias tmacs='emacs -nw'
