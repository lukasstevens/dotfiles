# Path to your oh-my-zsh installation.
export ZSH=$HOME/.oh-my-zsh

# Absolute path of this config
SCRIPT_DIR=$(dirname $(realpath ${(%):-%x}))

# Set name of the theme to load.
# Look in ~/.oh-my-zsh/themes/
# Optionally, if you set this to "random", it'll load a random theme each
# time that oh-my-zsh is loaded.
ZSH_THEME="robbyrussell"

# Auto-completion
CASE_SENSITIVE="false"
HYPHEN_INSENSITIVE="false"

# Updates
DISABLE_AUTO_UPDATE="false"
export UPDATE_ZSH_DAYS=13

DISABLE_LS_COLORS="false"
DISABLE_AUTO_TITLE="false"

# Command correction
ENABLE_CORRECTION="false"

COMPLETION_WAITING_DOTS="true"

# Untracked files are marked as dirty
DISABLE_UNTRACKED_FILES_DIRTY="false"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# The optional three formats: "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# HIST_STAMPS="mm/dd/yyyy"

CONFIG_DIR=$SCRIPT_DIR/.zshrc.d/

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
plugins=(git bookmark)

# User configuration

# Shell coloring
base16_shell=$SCRIPT_DIR/colors/my-base16.sh
[[ -s $base16_shell ]] && source $base16_shell

# Aliases
source $CONFIG_DIR/zsh_aliases

# End user configuration

export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/usr/lib/jvm/java-8-oracle/bin:/usr/lib/jvm/java-8-oracle/db/bin:/usr/lib/jvm/java-8-oracle/jre/bin"
export MANPATH="/usr/local/man:$MANPATH"

source $ZSH/oh-my-zsh.sh
