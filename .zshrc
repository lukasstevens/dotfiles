source /usr/share/zsh-antigen/antigen.zsh || echo "You need to install antigen first."

# Absolute path of this config
SCRIPT_DIR=$(dirname $(realpath ${(%):-%x}))

# Other paths
CONFIG_DIR=$SCRIPT_DIR/.zshrc.d/

# Antigen plugins
antigen use oh-my-zsh

antigen theme agnoster

antigen bundle git
antigen bundle git-extras
antigen bundle npm
antigen bundle pip
antigen bundle python
antigen bundle wd
antigen bundle thefuck
antigen bundle dickeyxxx/gh zsh/gh

antigen apply

# User configuration

# Shell coloring
base16_shell=$SCRIPT_DIR/colors/my-base16.sh
[[ -s $base16_shell ]] && source $base16_shell

# Additional configuration
source $CONFIG_DIR/*

# virtualenv
source /usr/local/bin/virtualenvwrapper_lazy.sh

# End user configuration

export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/usr/lib/jvm/java-8-oracle/bin:/usr/lib/jvm/java-8-oracle/db/bin:/usr/lib/jvm/java-8-oracle/jre/bin:/home/lukas/.cargo/bin"
export MANPATH="/usr/local/man:$MANPATH"
# virtualenv env variables
export WORKON_HOME=$HOME/.virtualenvs
export VIRTUALENVWRAPPER_PYTHON=$(which python3)
