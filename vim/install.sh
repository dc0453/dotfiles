# !/usr/bin/env bash
base_dir="$HOME/.spf13-vim-3"
spf13_script="$HOME/spf13-vim.sh"
echo "installing spf13-vim-3"

if [[ ! -d $base_dir ]]; then
  echo "create new spf13-vim-3"
  #sh < $(curl -fsSL https://j.mp/spf13-vim3)
  curl https://j.mp/spf13-vim3 -L > $spf13_script && sh $spf13_script
fi

echo "install spf13-vim done"