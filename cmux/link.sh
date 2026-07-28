#!/usr/bin/env bash

DOTFILES_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
source "$DOTFILES_ROOT/script/utils.sh"

SOURCE="$DOTFILES_ROOT/cmux/cmux.json"
TARGET_DIR="$HOME/.config/cmux"
TARGET="$TARGET_DIR/cmux.json"

info "linking cmux configuration"
mkdir -p "$TARGET_DIR"

if [[ -L "$TARGET" && "$(realpath "$TARGET")" == "$(realpath "$SOURCE")" ]]; then
  info "cmux configuration already linked, skipping"
  exit 0
fi

if [[ -e "$TARGET" || -L "$TARGET" ]]; then
  mv "$TARGET" "${TARGET}.backup.$(date +%Y%m%d%H%M%S)"
  warn "existing cmux configuration backed up"
fi

ln -s "$SOURCE" "$TARGET"
success "cmux configuration linked: $TARGET -> $SOURCE"
