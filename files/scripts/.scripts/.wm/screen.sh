#!/bin/sh

# Author: Jarrod Cameron (z5210220)

BLACK="#282828"
WHITE="#ebdbb2"
GRAY="#1d2021"
AQUA="#689d68"
COLORS="-nb $BLACK -nf $WHITE -sf $GRAY -sb $AQUA"

# Prints all possible resolutions such that both screens can be the
# same resolution
get_sizes () {
    xrandr --query | awk '/^\s+[0-9]+x[0-9]+ / {print $1}' | sort -rn | uniq -c | awk '/ 2 / {print $2}'
}

# Prompt the user and return the desired mode for both of the screens
get_mode_both () {
    primary="$1"
    secondary="$2"

    height="$(get_sizes | wc -l)"
    get_sizes | dmenu -i -l $height -p "Choose size:" $COLORS
}

# A simple menu to prompt the user to choose what screen to update
choose_screen () {
    printf "\
primary
secondary
both" | dmenu -i -l 3 -p "Choose screen:" $COLORS
}

# Simply print the list of resolutions for the particular screen
print_modes () {
    screen="$1"

    xrandr --query | awk '
    BEGIN {
        stage = 0
        screen="'"$screen"'"
    }
    {
        if (stage == 0) {
            if ($1 == screen) {
                stage = 1
            }
        } else if (stage == 1) {
            if (match($0, "^   [0-9]+x[0-9]+") == 0) {
                stage = 2
            } else if (match($1, "i$") == 0) {
                printf "%s\n", $1
            }
        }
    }'
}

# Print a list of all posible modes (i.e. resolutions for the type of screen).
# If there are no modes print nothing
get_mode () {
    screen="$1"
    height="$(print_modes "$screen" | wc -l)"
    print_modes "$screen" | dmenu -i -l "$height" -p "Choose mode:" $COLORS
}

# Set the dimensions for one or both of the screens
set_dims () {
    primary="$1"
    secondary="$2"

    screen="$(choose_screen)"

    case "$screen" in
        'primary')   mode="$(get_mode "$primary")"   ;;
        'secondary') mode="$(get_mode "$secondary")" ;;
        'both')      mode="$(get_mode_both)"         ;;
        *) exit 1                                    ;;
    esac

    if [ -z "$mode" ]; then
        exit 1
    fi

    if [ "$screen" = 'primary' ] || [ "$screen" = 'both' ]; then
        xrandr --output "$primary" --mode "$mode"
    fi

    if [ "$screen" = 'secondary' ] || [ "$screen" = 'both' ]; then
        xrandr --output "$secondary" --mode "$mode"
    fi

}

eval $(xrandr --query | awk '
BEGIN {
    count = 0
}
/ connected / {
    if (count == 0) {
        printf "primary=\"%s\";\n", $1
        count = 1
    } else if (count == 1) {
        printf "secondary=\"%s\";\n", $1
        count = 2
    }
}')

options="$({
    printf "\
Extend Right (ER)
Extend Left (EL)
Duplicate (D)
Set Dimensions (SD)
Kill (K)"
})"

height="$(echo "$options" | wc -l)"
output="$(echo "$options" | dmenu -i -l $height -p "Secondary output:" $COLORS)"

case "$output" in
  "Extend Right (ER)")   xrandr --output "$secondary" --auto --right-of "$primary" ;;
  "Extend Left (EL)")    xrandr --output "$primary" --auto --right-of "$secondary" ;;
  "Duplicate (D)")       xrandr --output "$secondary" --auto --same-as "$primary"  ;;
  "Set Dimensions (SD)") set_dims "$primary" "$secondary"                          ;;
  "Kill (K)")            xrandr --output "$secondary" --auto --off                 ;;
esac
