#!/usr/bin/env bash

KARABINER_CONFIG="${HOME}/.config/karabiner"
KARABINER_ASSETS="${KARABINER_CONFIG}/assets"


echo "configing karabiner"

script_dir="$(dirname "$0")"
base_dir=`cd $script_dir && pwd`

# copy my complex_modifications
ln -s $base_dir/complex_modifications/* $KARABINER_ASSETS/complex_modifications/
# copy my karabiner.json
ln -s $base_dir/karabiner.json $KARABINER_CONFIG/

echo "config karabiner done"
