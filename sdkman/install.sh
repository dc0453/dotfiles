#!/bin/sh
#
# dot
#
# `dot` handles installation, updates, things like that. Run it periodically
# to make sure you're on the latest and greatest.

cd "$(dirname "$0")/.."
DOTFILES_ROOT=$(pwd)

# 检查sdkman是否已安装
if [ -f "$HOME/.sdkman/bin/sdkman-init.sh" ]; then
    echo "Sdkman 已安装，跳过安装步骤"
else
    # https://sdkman.io/install/
    curl -s "https://get.sdkman.io" | bash
    echo "Sdkman 安装完成"
fi
