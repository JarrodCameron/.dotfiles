#    _               _
#   | |             | |
#   | |__   __ _ ___| |__  _ __ ___
#   | '_ \ / _` / __| '_ \| '__/ __|
#  _| |_) | (_| \__ \ | | | | | (__
# (_)_.__/ \__,_|___/_| |_|_|  \___|

# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# Bash formatting constants
BOLD="\e[1m"
ULINE="\e[4m"
RESET="\e[0m"
RED="\e[31m"
GREEN="\e[32m"

export TERM=xterm-256color

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# Change directory using filename
shopt -s autocd

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=20000
HISTFILESIZE=20000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
        # We have color support; assume it's compliant with Ecma-48
        # (ISO/IEC-6429). (Lack of such support is extremely rare, and such
        # a case would tend to support setf rather than setaf.)
        color_prompt=yes
    else
        color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias dir='dir --color=auto'
    alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# colored GCC warnings and errors
#export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

##########
# CUSTOM #
##########

# Export colors used in man pages, less, etc
export LESS_TERMCAP_mb=$(printf "\e[1;34m")
export LESS_TERMCAP_md=$(printf "\e[1;34m")
export LESS_TERMCAP_me=$(printf "\e[0m")
export LESS_TERMCAP_se=$(printf "\e[0m")
export LESS_TERMCAP_so=$(printf "\e[1;44;33m")
export LESS_TERMCAP_ue=$(printf "\e[0m")
export LESS_TERMCAP_us=$(printf "\e[1;32m")

#if [[ $TERM != linux && ! $PROMPT_COMMAND =~ _update_ps1 ]]; then
#    PROMPT_COMMAND="_update_ps1; $PROMPT_COMMAND"
#fi

export MANWIDTH=80
export MANPAGER="/bin/sh -c \"col -b | vim --not-a-term -c 'set ft=man ts=8 nomod nolist noma' -\""

# Bash with vim keys (god tier bash mode)
set -o vi

## `export' sets global variables
export PATH="$PATH"":""$HOME""/.scripts/"
export EDITOR="$(which vim)"
#export TERMINAL="$(which st)"

# Copy
alias copy="xclip -selection clip 2> /dev/null"

alias r2="radare2"

alias csc="cscope -R -k"
alias tag="vim -t"
alias cse="ssh -i ~/.ssh/cse z5210220@cse.unsw.edu.au"
alias objdump="objdump -Mintel"
alias p="python3 -q"
alias gdb="bash ~/.scripts/.alias/gdb_alias.sh"
alias rr="ranger"
alias bim="vim"
alias gim="vim"
alias v="vim"
alias LS="ls"
alias sl="ls"
alias s="ls"
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../.."
alias vv="vim ."
alias retag="rm -f tags ; ctags -R"
alias q="exit"
alias mkae="make"
alias mak="make"
alias z="zathura --fork"
alias ctf="cd ~/repos/ctfsolns/"
alias cs="cd ~/cs3231/asst2-src/ && rm -f tags && ctags -R && cscope -R -k"
alias todo="rg TODO"
alias gdbinit="vim gdbinit"
alias 2121="cd ~/repos/2121/"
alias 4337="cd ~/repos/4337/"
alias R='R --quiet --vanilla'

alias dumbshell='setarch `uname -m` -R /bin/bash'

function aslr () {
    if [ -z "$1" ]; then
        echo "Usage: aslr [off]"
    elif [ "$1" = "off" ]; then
        echo -e "ASLR is ""$BOLD$RED""OFF""$RESET"
        setarch `uname -m` -R `which bash`
    else
        echo "Usage: aslr [off]"
    fi
}

# This is a logout function which only should be used on cse machines
if [ "$USER" = 'z5210220' ]; then
	alias logout="pkill -u z5210220"
fi

# Open up a tar file
alias untar="tar -xvf"

# Disable terminal beeps
stty -ixon

# Print out todo list
~/.scripts/.bash/todo_list.sh

# Key bindings
bind -x '"\C-f": ~/.scripts/.bash/open_fuzzy.sh'
bind -x '"\C-h": ~/.scripts/.bash/open_history.sh'
bind -x '"\C-t": ~/.scripts/.bash/open_todo.sh'
bind -x '"\C-a": ~/.scripts/.bash/open_man.sh'