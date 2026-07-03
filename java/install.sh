#!/usr/bin/env bash

DOTFILES_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
source "$DOTFILES_ROOT/script/utils.sh"

# Java版本变量
JAVA_VERSION="17.0.15-amzn"

# 检查sdkman是否已安装
if [ -f "$HOME/.sdkman/bin/sdkman-init.sh" ]; then
    source "$HOME/.sdkman/bin/sdkman-init.sh"
    
    # 检查指定Java版本是否已安装
    if ! sdk list java | grep -q "$JAVA_VERSION"; then
        sdk install java $JAVA_VERSION
    else
        info "Java $JAVA_VERSION 已安装"
    fi
else
    warn "SDKMAN 未安装，跳过 Java 安装步骤"
fi
