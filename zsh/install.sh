#!/usr/bin/env zsh

ZSH="${HOME}/.oh-my-zsh"

script_dir="$(dirname "$0")"
base_dir=`cd $script_dir && pwd`

# copy my themes to custom dir
cp -rf $base_dir/themes $ZSH/custom/
#source ${HOME}/.zshrc