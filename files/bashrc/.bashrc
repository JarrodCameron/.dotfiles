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
export RUN_ZID=z5210220

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

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '

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

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

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

export EDITOR=vim

# Make `cd' better
bind 'set completion-ignore-case on'
complete -d cd

# Export colors used in man pages, less, etc
export LESS_TERMCAP_mb=$(printf "\e[1;34m")
export LESS_TERMCAP_md=$(printf "\e[1;34m")
export LESS_TERMCAP_me=$(printf "\e[0m")
export LESS_TERMCAP_se=$(printf "\e[0m")
export LESS_TERMCAP_so=$(printf "\e[1;44;33m")
export LESS_TERMCAP_ue=$(printf "\e[0m")
export LESS_TERMCAP_us=$(printf "\e[1;32m")

export MANWIDTH=80
export MANPAGER="/bin/sh -c \"col -b | vim --not-a-term -c 'set ft=man ts=8 nomod nolist noma' -\""

# Bash with vim keys (god tier bash mode)
set -o vi

## `export' sets global variables
export PATH="$PATH"":""$HOME""/.scripts/"
export EDITOR="$(which vim)"

# Copy
alias copy="xclip -selection clip 2> /dev/null"
alias r2="radare2"
alias tag="vim -t"
alias cse="ssh z5210220@cse.unsw.edu.au"
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
alias q="exit"
alias mkae="make"
alias mak="make"
alias z="zathura --fork"
alias cs="cd ~/cs3231/asst2-src/ && rm -f tags && ctags -R && cscope -R -k"
alias gdbinit="vim gdbinit"
alias R='R --quiet --vanilla'
alias cp='cp -i'
alias mv='mv -i'
alias dumbshell='setarch `uname -m` -R /bin/bash'
alias 20t1='cd ~/repos/20t1 && br -f && clear && ls -l'
alias music='cd ~/music && mpv $(ls [0-9][0-9].mp3 | sort -R | tr "\n" " ")'
alias ui='cd /usr/include'
alias tmp='cd "$(mktemp -d)"'
alias rg='rg --no-ignore'

function csc () {
	rm -f tags
	ctags -R &
	cscope -R -k
}

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

#source /home/jc/.config/broot/launcher/bash/br
function br {
	f=$(mktemp)
	(
		set +e
		broot --outcmd "$f" "$@"
		code=$?
		if [ "$code" != 0 ]; then
			rm -f "$f"
			exit "$code"
		fi
	)
	code=$?
	if [ "$code" != 0 ]; then
		return "$code"
	fi
	d=$(<"$f")
	rm -f "$f"
	eval "$d"
}
