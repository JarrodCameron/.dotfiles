#
# ~/.bash_profile
#

[[ -f ~/.bashrc ]] && . ~/.bashrc

# tmux likes to source the .bash_profile for some reason...
if [ -z "$(pidof ssh-agent)" ]; then
	eval $(ssh-agent) &>/dev/null
fi

#if systemctl -q is-active graphical.target ; then
#	if [[ ! "$DISPLAY" && "$XDG_VTNR" -eq 1 ]]; then
#		exec startx
#	fi
#fi

