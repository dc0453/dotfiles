#!/usr/bin/env bash

DOTFILES_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
source "$DOTFILES_ROOT/script/utils.sh"

SDKMAN_INIT="$HOME/.sdkman/bin/sdkman-init.sh"

# ── 安装 sdkman ──────────────────────────────────────────────────────────────

if [ -f "$SDKMAN_INIT" ]; then
    info "sdkman 已安装，跳过安装"
else
    info "安装 sdkman..."
    curl -s "https://get.sdkman.io" | bash
    info "sdkman 安装完成"
fi

# ── 加载 sdkman ──────────────────────────────────────────────────────────────

source "$SDKMAN_INIT"

# ── 安装 Java 8.0.482-kona ───────────────────────────────────────────────────

JAVA_VERSION="8.0.482-kona"

if sdk list java | grep -q "${JAVA_VERSION}.*installed"; then
    info "Java ${JAVA_VERSION} 已安装，跳过"
else
    info "安装 Java ${JAVA_VERSION}..."
    sdk install java "${JAVA_VERSION}"
fi

info "设置 Java ${JAVA_VERSION} 为默认版本..."
sdk default java "${JAVA_VERSION}"
