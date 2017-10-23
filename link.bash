#!/bin/bash

# get the absolute path of this script
pushd . > /dev/null
script_path="${BASH_SOURCE[0]}";
while([ -h "${script_path}" ]); do
    cd "`dirname "${script_path}"`"
    script_path="$(readlink "`basename "${script_path}"`")";
done
cd "`dirname "${script_path}"`" > /dev/null
script_path="`pwd`";
popd  > /dev/null

link_names=(
	"$HOME/.bashrc"
	"$HOME/.emacs.d"
	"$HOME/.config/i3"
	"$HOME/.inputrc"
	"$HOME/.vimrc"
	"$HOME/.Xresources"
	"$HOME/.zshenv"
	"$HOME/.zshrc")

file_names=(
	"bashrc"
	"emacs.d"
	"i3"
	"inputrc"
	"vimrc"
	"Xresources"
	"zshenv"
	"zshrc")


for i in "${!file_names[@]}"; 
do
    rm ${link_names[$i]}
    ln -s $script_path/${file_names[$i]} ${link_names[$i]}
done

echo ". $HOME/dotfiles/xsessionrc" > "$HOME/.xsessionrc"
