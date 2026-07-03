#!/usr/bin/env bash

DOTFILES_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
source "$DOTFILES_ROOT/script/utils.sh"

ZSH="${HOME}/.oh-my-zsh"

install_ohmyzsh () {
  if [ ! -d ${ZSH} ]
  then
    info 'installing oh-my-zsh'
    # RUNZSH=no  : 安装后不自动启动 zsh（避免 bootstrap 卡死）
    # CHSH=no    : 不自动修改默认 shell（避免需要 sudo 密码导致挂起）
    RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --keep-zshrc
  else
    info 'oh-my-zsh already installed, skipping'
  fi
}

info "installing oh-my-zsh"

install_ohmyzsh

base_dir="$(cd "$(dirname "$0")" && pwd)"

# 将自定义 plugins/themes 软链到 oh-my-zsh custom 目录
# -f 覆盖已存在的链接，逐个处理避免 glob 展开失败时整体报错
for plugin in "$base_dir/custom/plugins"/*/; do
  ln -sf "$plugin" "$ZSH/custom/plugins/"
done

for theme in "$base_dir/custom/themes"/*.zsh-theme; do
  [ -f "$theme" ] && ln -sf "$theme" "$ZSH/custom/themes/"
done
#source ${HOME}/.zshrc

info "install oh-my-zsh done"
