#####################################
## THIS FILE IS MANAGED BY ANSIBLE ##
#####################################

# Source global definitions
if [ -f /etc/bash.bashrc ]; then
        . /etc/bash.bashrc
fi

if [ -f /etc/bash_completion ]; then
 . /etc/bash_completion
fi

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

if [ -f ~/.bash_custom ]; then
    . ~/.bash_custom
fi

export HISTSIZE=2000
export HISTFILESIZE=5000

export HISTTIMEFORMAT="%d/%m/%y %T "
export LS_OPTIONS='--color=auto'

