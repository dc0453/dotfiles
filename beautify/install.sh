#!/usr/bin/env bash

DOTFILES_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
source "$DOTFILES_ROOT/script/utils.sh"

plugins="${HOME}/.plugins"

IS_MAC_OS=""
if [[ "$OSTYPE" == darwin* ]]; then
    IS_MAC_OS=true
fi

mkdir -p "${plugins}"
cd "${plugins}"

# ── Powerline fonts ──────────────────────────────────────────────────────────
if [[ ! -d "${plugins}/fonts" ]]; then
    info "cloning powerline fonts..."
    if git clone --depth=1 https://github.com/powerline/fonts.git; then
        sh ./fonts/install.sh
        success "powerline fonts installed"
    else
        warn "failed to clone powerline/fonts, skipping"
    fi
else
    info "powerline fonts already installed, skipping"
fi

# ── Solarized ────────────────────────────────────────────────────────────────
if [[ ! -d "${plugins}/solarized" ]]; then
    info "cloning solarized..."
    if git clone --depth=1 https://github.com/altercation/solarized.git; then
        success "solarized cloned"
        if [[ "$IS_MAC_OS" == true ]]; then
            if [[ -d "/Applications/iTerm.app" ]]; then
                open "${plugins}/solarized/iterm2-colors-solarized/Solarized Dark.itermcolors"
            else
                warn "iTerm2 not found, manually open to import color scheme:"
                echo "   ${plugins}/solarized/iterm2-colors-solarized/Solarized Dark.itermcolors"
            fi
            if [[ -d "/Applications/Utilities/Terminal.app" ]]; then
                open "${plugins}/solarized/osx-terminal.app-colors-solarized/xterm-256color/Solarized Dark xterm-256color.terminal"
            fi
        fi
    else
        warn "failed to clone solarized, skipping"
    fi
else
    info "solarized already installed, skipping"
fi

# ── dircolors-solarized ──────────────────────────────────────────────────────
if [[ ! -d "${plugins}/dircolors-solarized" ]]; then
    info "cloning dircolors-solarized..."
    git clone --depth=1 https://github.com/seebi/dircolors-solarized.git \
        || warn "failed to clone dircolors-solarized, skipping"
else
    info "dircolors-solarized already installed, skipping"
fi
