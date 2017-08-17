typeset -U PATH 
PATH="$HOME/.local/bin:$HOME/.cargo/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/lib/jvm/java-8-oracle/bin:/usr/lib/jvm/java-8-oracle/db/bin:/usr/lib/jvm/java-8-oracle/jre/bin:$PATH"
typeset -U MANPATH
MANPATH="/usr/local/man:$MANPATH"
# virtualenv
if [ -f /usr/local/bin/virtualenvwrapper_lazy.sh ]; then
    source /usr/local/bin/virtualenvwrapper_lazy.sh
fi
# virtualenv env variables
typeset -x WORKON_HOME 
WORKON_HOME=~/.virtualenvs
typeset -x VIRTUALENVWRAPPER_PYTHON 
VIRTUALENVWRAPPER_PYTHON=$(which python3)
# Rust variables
typeset -x RUST_SRC_PATH
RUST_SRC_PATH=~/.multirust/toolchains/nightly-x86_64-unknown-linux-gnu/lib/rustlib/src/rust/src
# Go
typeset -x GOPATH 
GOPATH=$HOME/src/gocode
typeset -U PATH
PATH="$GOPATH/bin:$PATH"
# npm
typeset -U PATH
PATH="$HOME/.local/share/npm-packages/bin:$PATH"
# pass
typeset -x PASSWORD_STORE_TOMB_FILE
PASSWORD_STORE_TOMB_FILE="$HOME/ownCloud/password.tomb"
typeset -x PASSWORD_STORE_TOMB_KEY
PASSWORD_STORE_TOMB_KEY="$HOME/ownCloud/password.tomb.key"

fpath+=~/.zfunc
