#!/usr/bin/env bash

KARABINER_ASSETS="${HOME}/.config/karabiner/assets"


echo "configing karabiner"

script_dir="$(dirname "$0")"
base_dir=`cd $script_dir && pwd`

# copy my complex_modifications
ln -s $base_dir/complex_modifications/* $KARABINER_ASSETS/complex_modifications/

echo "config karabiner done"
