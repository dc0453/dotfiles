#!/bin/sh

plugins=(
    virtualenv
    powerline-status
    autopep8
    flake8
    docopt
    pytz
    requests
    unittest2
    thefuck
)
if test ! $(which pip)
then
    echo "no python pip, exit"
    exit 0
fi

sudo pip install --upgrade pip

# pyenv
curl -L https://raw.githubusercontent.com/yyuu/pyenv-installer/master/bin/pyenv-installer | bash

sudo pip install ${plugins[@]}