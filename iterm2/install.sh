#!/usr/bin/env bash
#
# iterm2 config

DOTFILES_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
source "$DOTFILES_ROOT/script/utils.sh"

IS_MAC_OS=""
if [[ "$OSTYPE" == darwin* ]]; then
    IS_MAC_OS=true
fi

if [[ "$IS_MAC_OS" == true ]]; then
    info "start config iterm2"

    # Specify the preferences directory
    defaults write com.googlecode.iterm2.plist PrefsCustomFolder -string "$DOTFILES_ROOT/iterm2"
    # Tell iTerm2 to use the custom preferences in the directory
    defaults write com.googlecode.iterm2.plist LoadPrefsFromCustomFolder -bool true

    success "config iterm2 done"
fi

exit 0
