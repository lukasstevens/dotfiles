if [ -e "$HOME/.nix-profile/etc/profile.d/nix.sh" ]; then
    . "$HOME/.nix-profile/etc/profile.d/nix.sh"
    export NIX_PATH=$HOME/.nix-defexpr/channels${NIX_PATH:+:}$NIX_PATH
fi

export PATH="$HOME/.local/bin:$HOME/.cargo/bin:$PATH"

if [ -e "/usr/bin/manpath" ]; then
    export MANPATH="$(/usr/bin/manpath -g):$MANPATH"
fi 
