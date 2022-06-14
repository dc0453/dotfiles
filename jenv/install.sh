#!/bin/sh
#
# dot
#
# `dot` handles installation, updates, things like that. Run it periodically
# to make sure you're on the latest and greatest.

cd "$(dirname "$0")/.."
DOTFILES_ROOT=$(pwd)

IS_MAC_OS=""
if [[ "$OSTYPE" == darwin* ]]; then
      IS_MAC_OS=true
fi

if [[ "$IS_MAC_OS" == true ]]; then
    jenv add /Library/Java/JavaVirtualMachines/adoptopenjdk-8.jdk/Contents/Home
fi

# https://github.com/jenv/jenv
# To make sure JAVA_HOME is set, make sure to enable the export plugin:
jenv enable-plugin export
# exec $SHELL -l
