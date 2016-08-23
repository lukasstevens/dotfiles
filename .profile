export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/usr/lib/jvm/java-8-oracle/bin:/usr/lib/jvm/java-8-oracle/db/bin:/usr/lib/jvm/java-8-oracle/jre/bin:$PATH"
export MANPATH="/usr/local/man:$MANPATH"
# virtualenv
source /usr/local/bin/virtualenvwrapper_lazy.sh
# virtualenv env variables
export WORKON_HOME=$HOME/.virtualenvs
export VIRTUALENVWRAPPER_PYTHON=$(which python3)
# rust
source $HOME/.cargo/env
