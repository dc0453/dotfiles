#!/usr/bin/env bash

DOTFILES_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
source "$DOTFILES_ROOT/script/utils.sh"

SOURCE="$DOTFILES_ROOT/snapzy/config.toml"
TARGET_DIR="$HOME/.config/snapzy"
TARGET="$TARGET_DIR/config.toml"

info "configuring Snapzy..."
mkdir -p "$TARGET_DIR"

if [[ -L "$TARGET" && "$(realpath "$TARGET")" == "$(realpath "$SOURCE")" ]]; then
  info "Snapzy configuration already linked, skipping"
  exit 0
fi

if [[ -e "$TARGET" || -L "$TARGET" ]]; then
  mv "$TARGET" "${TARGET}.backup.$(date +%Y%m%d%H%M%S)"
  warn "existing Snapzy configuration backed up"
fi

ln -s "$SOURCE" "$TARGET"
success "Snapzy configuration linked: $TARGET -> $SOURCE"
