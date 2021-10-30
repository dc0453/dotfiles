# !/bin/bash
#
# iterm2 config 

IS_MAC_OS=""
if [[ "$OSTYPE" == darwin* ]]; then
    IS_MAC_OS=true
fi

cd "$(dirname "$0")/.."
DOTFILES_ROOT=$(pwd)

if [[ "$IS_MAC_OS" == true ]]; then
    echo "start config iterm2"

    # Specify the preferences directory
    defaults write com.googlecode.iterm2.plist PrefsCustomFolder -string "$DOTFILES_ROOT/iterm2"
    # Tell iTerm2 to use the custom preferences in the directory
    defaults write com.googlecode.iterm2.plist LoadPrefsFromCustomFolder -bool true

    echo "config iterm2 done"
fi

exit 0
