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
    cp ${plugins}/.tmux/.tmux.conf.local ~/.tmux.conf.local
fi

echo "[done] install tmux config"

exit 0
