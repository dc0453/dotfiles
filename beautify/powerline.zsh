# powerline terminal
if test $(which pip)
then
    export POWERLINE_ROOT=$(python -c "from distutils.sysconfig import get_python_lib; print get_python_lib()")/powerline
    #. ${POWERLINE_ROOT}/bindings/zsh/powerline.zsh
fi