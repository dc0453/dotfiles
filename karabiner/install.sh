#!/usr/bin/env bash

DOTFILES_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
source "$DOTFILES_ROOT/script/utils.sh"

KARABINER_CONFIG="${HOME}/.config/karabiner"
KARABINER_ASSETS="${KARABINER_CONFIG}/assets"

info "configing karabiner"

script_dir="$(dirname "$0")"
base_dir=$(cd $script_dir && pwd)

mkdir -p "$KARABINER_ASSETS/complex_modifications"

# copy my complex_modifications（-sf 覆盖已存在的链接）
for mod in "$base_dir/complex_modifications"/*.json; do
  [ -f "$mod" ] && ln -sf "$mod" "$KARABINER_ASSETS/complex_modifications/"
done

# copy my karabiner.json
ln -sf "$base_dir/karabiner.json" "$KARABINER_CONFIG/"

success "config karabiner done"
