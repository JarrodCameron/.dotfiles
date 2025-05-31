#
# ~/.bash_profile
#

[[ -f ~/.bashrc ]] && . ~/.bashrc

# tmux likes to source the .bash_profile for some reason...
[ -z "$(pidof ssh-agent)" ] && eval $(ssh-agent) &>/dev/null

if systemctl -q is-active graphical.target ; then
	if [[ ! "$DISPLAY" && "$XDG_VTNR" -eq 1 ]]; then

		export XDG_CONFIG_HOME="$HOME/.config"
		export XDG_CACHE_HOME="$HOME/.cache"
		export XDG_DATA_HOME="$HOME/.local/share"

		log_dir="$XDG_CACHE_HOME/dwl"
		mkdir -p "$log_dir"

		slstatus -s | dwl > "$log_dir/stdout.log" 2> "$log_dir/stderr.log"
	fi
fi
