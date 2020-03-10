#!/bin/sh

# Author: Jarrod Cameron (z5210220)
# Date:   29/12/19  9:48

DOTFILES_JSON="$HOME"'/.dotfiles/dotfiles.json'

[ -z "$EDITOR" ] && EDITOR="$(which vim)"
[ -z "$TERMINAL" ] && TERMINAL="$(which termite)"

# Simple dmenu wrapper
run_dmenu () {
    height="$1"
    prompt="$2"
    IFS=''
    while read line
    do
        printf "%s\n" "$line"
    done | dmenu -i -l "$height" -p "$prompt" \
            -fn 'monospace:size=14' \
            -nb "#282828" \
            -nf "#ebdbb2" \
            -sf "#1d2021" \
            -sb "#689d68"
}

# List all files in a directory
run_dir () {
    init_dur="$1"

    # Maximium 20 entries
    height="$(find -L "$init_dur" -type f | head -n 20 | wc -l)"

    new_file="$(find -L "$init_dur" -type f | run_dmenu "$height" "Edit file:")"

    printf "%s" "$new_file"
}

num_files="$(jq '. | length' "$DOTFILES_JSON")"
last_index="$((num_files-1))"

# Add entries here
conf_file="$({
    printf '%s\n' "\
${HOME}/.bashrc
${HOME}/.config/bspwm/bspwmrc
${HOME}/.config/i3/i3
${HOME}/.config/i3blocks/i3blocks
${HOME}/.config/radare2/radare2rc
${HOME}/.config/sxhkd/sxhkdrc
${HOME}/.config/termite/config
${HOME}/.config/xmobar/xmobarrc
${HOME}/.gdbinit
${HOME}/.scripts
${HOME}/.tmux.conf
${HOME}/.cache/todo
${HOME}/.vim
${HOME}/.vim/vimrc
${HOME}/.xmonad/xmonad.hs
"
} | run_dmenu "$num_files" "Edit file:")"

if [ -z "$conf_file" ]; then
    exit 0
elif [ -d "$conf_file" ]; then
    conf_file="$(run_dir "${conf_file}")"
fi

cmd="$EDITOR $conf_file"

$TERMINAL -e "$cmd"
