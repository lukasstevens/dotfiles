typeset -U PATH 
PATH="$HOME/.local/bin:$HOME/.cargo/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:$PATH"
typeset -U MANPATH
MANPATH="/usr/local/man:$MANPATH"
# Rust variables
typeset -x RUST_SRC_PATH
RUST_SRC_PATH=~/.multirust/toolchains/nightly-x86_64-unknown-linux-gnu/lib/rustlib/src/rust/src

eval `opam config env`

eval "$(direnv hook zsh)"

fpath+=~/.zfunc
