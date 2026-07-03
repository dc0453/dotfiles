#!/usr/bin/env bash

DOTFILES_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
source "$DOTFILES_ROOT/script/utils.sh"

script_dir="$(dirname "$0")"
base_dir=$(cd $script_dir && pwd)

plugins=${HOME}/.plugins

info "installing tmux config"

IS_MAC_OS=""
if [[ "$OSTYPE" == darwin* ]]; then
      IS_MAC_OS=true
fi

if [[ ! -d ${plugins} ]]; then
    mkdir ${plugins}
fi

cd ${plugins}

# install oh-my-tmux
if [[ ! -d ${plugins}/.tmux ]]; then
	git clone https://github.com/gpakosz/.tmux.git
    ln -s -f ${plugins}/.tmux/.tmux.conf ~/.tmux.conf
fi

# link my customized configuration
#ln -s -f ${base_dir}/tmux.conf.local.symlink ~/.tmux.conf.local
success "install tmux config done"

exit 0
