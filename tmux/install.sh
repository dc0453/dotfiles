# !/bin/sh

plugins=${HOME}/.plugins

echo "[start] installing tmux config"

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

script_dir="$(dirname "$0")"
base_dir=`cd $script_dir && pwd`

# link my customized configuration
ln -s -f ${base_dir}/.tmux/.tmux.conf.local ~/.tmux.conf.local
echo "[done] install tmux config"

exit 0
