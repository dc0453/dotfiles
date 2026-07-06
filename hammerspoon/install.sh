#!/usr/bin/env bash

DOTFILES_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
source "$DOTFILES_ROOT/script/utils.sh"

TARGET="$HOME/.hammerspoon"
SOURCE="$DOTFILES_ROOT/hammerspoon"

info "configing hammerspoon..."

# 已经是指向正确路径的软链，跳过
if [[ -L "$TARGET" && "$(realpath "$TARGET")" == "$(realpath "$SOURCE")" ]]; then
    info "hammerspoon already linked, skipping"
    exit 0
fi

# 已存在真实目录，备份后再建软链
if [[ -d "$TARGET" && ! -L "$TARGET" ]]; then
    mv "$TARGET" "${TARGET}.backup.$(date +%Y%m%d%H%M%S)"
    warn "existing ~/.hammerspoon backed up"
fi

ln -sf "$SOURCE" "$TARGET"
success "hammerspoon linked: ~/.hammerspoon -> $SOURCE"
