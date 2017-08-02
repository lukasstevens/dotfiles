source /usr/share/zsh-antigen/antigen.zsh &> /dev/null || source $HOME/.local/share/zsh-antigen/antigen.zsh &> /dev/null || echo "You need to install antigen first."

# Absolute path of this config
script_dir=$(dirname $(realpath ${(%):-%x}))

# Antigen plugins
antigen use oh-my-zsh

antigen theme agnoster

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

