# !/bin/sh

plugins=${HOME}/.plugins

IS_MAC_OS=""
if [[ "$OSTYPE" == darwin* ]]; then
      IS_MAC_OS=true
fi

if [[ ! -d ${plugins} ]]; then
    mkdir ${plugins}
fi

cd ${plugins}

# install powerline fonts
if [[ ! -d ${plugins}/fonts ]]; then
	git clone https://github.com/powerline/fonts.git
	sh ./fonts/install.sh
fi

# install solarized and dircolors
if [[ ! -d ${plugins}/solarized ]]; then
	git clone https://github.com/altercation/solarized.git
    if [[ "$IS_MAC_OS" == true ]]; then
      if [[ -d "/Applications/iTerm.app" ]]; then
        open "${plugins}/solarized/iterm2-colors-solarized/Solarized Dark.itermcolors"
      else
        echo "iTerm2 not found, skipping Solarized color scheme import. Install iTerm2 and manually open:"
        echo "  ${plugins}/solarized/iterm2-colors-solarized/Solarized Dark.itermcolors"
      fi
      if [[ -d "/Applications/Utilities/Terminal.app" ]]; then
        open "${plugins}/solarized/osx-terminal.app-colors-solarized/xterm-256color/Solarized Dark xterm-256color.terminal"
      fi
    fi
fi

if [[ ! -d ${plugins}/dircolors-solarized ]]; then
	git clone https://github.com/seebi/dircolors-solarized.git
fi

exit 0
