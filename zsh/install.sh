#!/usr/bin/env bash

ZSH="${HOME}/.oh-my-zsh"

install_ohmyzsh () {
  if [ ! -d ${ZSH} ]
  then
    info 'installing oh-my-zsh'
    sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)" "" --keep-zshrc
  fi
}

echo "installing oh-my-zsh"

install_ohmyzsh

script_dir="$(dirname "$0")"
base_dir=`cd $script_dir && pwd`

# copy my themes to custom dir
rm -rf $ZSH/custom/plugins
rm -rf $ZSH/custom/themes
ln -s $base_dir/custom/plugins $ZSH/custom/plugins
ln -s $base_dir/custom/themes $ZSH/custom/themes
#source ${HOME}/.zshrc

echo "install oh-my-zsh done"
