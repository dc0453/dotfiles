#!/bin/sh
#
# git config
#
echo "===================================="
echo "start config git global"

pwd_dir=$(cd `dirname $0`;pwd)
global_config_file=$pwd_dir/config.global

#cat $global_config_file 

IS_MAC_OS=""
if [[ "$OSTYPE" == darwin* ]]; then
      IS_MAC_OS=true
fi

# Install homebrew packages
if [[ "$IS_MAC_OS" == true ]]; then
  #sh $HOME/.dotfiles/homebrew/install.sh
  echo 
fi



while read line
do
    line=`echo $line | tr -d '\r\n'`
    git config --global $line
done < "$global_config_file";

echo "finish config git global"
