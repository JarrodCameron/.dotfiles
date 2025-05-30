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

# Shorten long ass paths in $PS1
# Example: '/mnt/c/Users/JarrodCameron/Desktop' -> /m/c/U/J/Desktop
_dump_path () {

    cwd="$(dirs +0)"
    cwdlen="$(/bin/echo -n "$cwd" | wc -c)"
    if [ "$cwdlen" -lt 30 ]; then
        dirs +0
        return
    fi

    prefix="$(dirs +0 | grep --only-matching '^[/]' || true)"
    path="$(dirs +0 \
        | sed 's#/#\n#g' \
        | head --lines -1 \
        | grep --only-matching '^.' \
        | tr '\n' '/'
    )"
    suffix="$(dirs +0 | sed 's#/#\n#g' | tail -n1)"

    echo "$prefix$path$suffix"
}

PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]$(_dump_path)\[\033[00m\]\$ '

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
export MANPAGER="/bin/sh -c \"col -b | vim --not-a-term -c 'set ft=man ts=8 nomod nolist' -\""

# Forces `groff' to output control characters in a format vim understands.
# `groff' is called internally when running man (which pipes into `vim')
export GROFF_NO_SGR=1

# Bash with vim keys (god tier bash mode)
set -o vi

## `export' sets global variables
if [[ "$PATH" != *"$HOME""/.scripts/"* ]]; then
	export PATH="$HOME""/.scripts/"":""$PATH"
fi
export EDITOR="$(which vim)"

alias r2="radare2"
alias tag="vim -t"
alias cse="ssh z5210220@cse.unsw.edu.au"
alias objdump="objdump -Mintel"
alias p="python3 -q"
alias gdb="bash ~/.scripts/.alias/gdb_alias.sh"
alias rr="ranger"
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
alias gdbinit="vim gdbinit"
alias R='R --quiet --vanilla'
alias cp='cp -i'
alias mv='mv -i'
alias dumbshell='setarch `uname -m` -R /bin/bash'
alias ui='cd /usr/include'
alias tmp='cd "$(mktemp -d)"'
alias rg='rg --no-ignore -g "!venv/" -g "!node_modules/"'
alias less='less -i'
alias hosts='cat /etc/hosts'
alias jim="jq | vim -c 'set ft=json' -c 'foldopen!' -"
alias hub='ssh hub'
alias jc='cd /mnt/c/Users/JarrodCameron/Desktop/'
alias c='cowsay'
alias ansi2text='sed -E "s/\x1b\[[0-9;]*m//g"'

# Because dwm sux
alias ghidra='_JAVA_AWT_WM_NONREPARENTING=1 ghidra'
alias burpsuite='_JAVA_AWT_WM_NONREPARENTING=1 burpsuite'

function regex101 () {
	echo 'UUIDs: \w{8}-\w{4}-\w{4}-\w{4}-\w{12}'
}

function music () {(
	cd ~/music
	while true
	do
		for f in `ls ~/music/*.mp3 | shuf`
		do
			mpv "$f"
		done
	done
)}

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
#bind -x '"\C-h": ~/.scripts/.bash/open_history.sh'
#bind -x '"\C-t": ~/.scripts/.bash/open_todo.sh'
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
alias nse-ls='ls /usr/bin/../share/nmap/scripts'


function bim {
	if [ -z "$TMUX" ]; then
		echo '+-------------------------------------+' >&2
		echo '| ERROR: We are not in a tmux buffer! |' >&2
		echo '+-------------------------------------+' >&2
		return
	fi

	tmpfile="$(mktemp)"
	lines="$(tput lines)"

	tmux capture-pane -S "-$lines"
	tmux save-buffer "$tmpfile"

	vim -c 'set ft=sh' "$tmpfile"

	source "$tmpfile"

	shred -u "$tmpfile"

}


function xdopaste () {

	data=''
	unix2dos='0'

	if [ "$#" -eq '1' ]; then
		data="$1"
	elif [ "$#" -eq '2' ] && [ "$2" = '--unix2dos' ]; then
		data="$1"
		unix2dos='1'
	else
		echo 'Usage: xdopaste <text|copy|-> [--unix2dos]' >&2
		return
	fi

	/bin/echo -n 'Copying in '
	for i in $(seq 5 -1 1)
	do
		/bin/echo -n "$i..."
		sleep 1
	done
	echo


	if [ -r "$data" ] || [ "$data" = '-' ]; then

		if [ "$unix2dos" -eq '1' ]; then
			unix2dos "$data"
		fi

		xdotool type --file "$data"

	elif [ "$unix2dos" -eq '1' ]; then
		/bin/echo -nE "$data" | unix2dos | xdotool type --file -
	else
		xdotool type "$data"
	fi
}

function wpath () {
    name="$1"
    realpath $name | sed 's#/#\\#g ; s/^/\\\\wsl.localhost\\kali-linux/'
}

function copy () {
	if [ -n "$WSL_DISTRO_NAME" ]; then
		# Running in WSL
		clip.exe
	else
		# X
		xclip -selection clip 2> /dev/null
	fi
}
