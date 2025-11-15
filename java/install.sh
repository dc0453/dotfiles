#!/bin/sh
#
# dot
#
# `dot` handles installation, updates, things like that. Run it periodically
# to make sure you're on the latest and greatest.

cd "$(dirname "$0")/.."
DOTFILES_ROOT=$(pwd)

# Java版本变量
JAVA_VERSION="17.0.15-amzn"

# 检查sdkman是否已安装
if [ -f "$HOME/.sdkman/bin/sdkman-init.sh" ]; then
    source "$HOME/.sdkman/bin/sdkman-init.sh"
    
    # 检查指定Java版本是否已安装
    if ! sdk list java | grep -q "$JAVA_VERSION"; then
        sdk install java $JAVA_VERSION
    else
        echo "Java $JAVA_VERSION 已安装"
    fi
else
    echo "SDKMAN 未安装，跳过 Java 安装步骤"
fi
