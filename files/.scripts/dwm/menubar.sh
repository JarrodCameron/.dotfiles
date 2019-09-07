#!/bin/sh

# Author: Jarrod Cameron (z5210220)
# Date:   04/09/19  7:56

# TODO:
# - memort
# - processors

NET_PREV_UP="0"
NET_PREV_DOWN="0"
NET_CURR_UP="0"
NET_CURR_DOWN="0"
INTERFACE=""

# Update variables associated with networking
update_nets () {
    INTERFACE=""
    for d in $(ls /sys/class/net/); do
        # NOTE: Loopback device (lo) is never up
        if [ "$(cat "/sys/class/net/""$d""/operstate")" = "up" ]; then
            INTERFACE="$d"
            break
        fi
    done
    if [ -z "$INTERFACE" ]; then
        NET_PREV_UP="0"
        NET_PREV_DOWN="0"
        NET_CURR_UP="0"
        NET_CURR_DOWN="0"
        return
    fi
    NET_PREV_UP="$NET_CURR_UP"
    NET_PREV_DOWN="$NET_CURR_DOWN"

    NET_CURR_UP="$(cat /proc/net/dev | awk '/^'$INTERFACE':/ {print $10}')"
    NET_CURR_DOWN="$(cat /proc/net/dev | awk '/^'$INTERFACE':/ {print $2}')"
}

get_date () {
    printf "%s" "$(date '+%A, %B, %d-%m-%Y %I:%M %p')"
}

get_vol () {
    # NOTE: Only tested with single sink
    local left="$(pacmd list-sinks | awk -F' ' '/volume: front/ {print $5}' | head -n1)"
    local right="$(pacmd list-sinks | awk -F' ' '/volume: front/ {print $12}' | head -n1)"

    # Trim last char (the `%')
    left=${left%?}
    right=${right%?}

    printf "Vol: %s" "$(echo "($left + $right) / 2" | bc )"
}

get_bat () {
    local full="$(cat /sys/class/power_supply/BAT0/charge_full)"
    local curr="$(cat /sys/class/power_supply/BAT0/charge_now)"
    local ratio="$(echo "100 * "$curr" / "$full"" | bc)%"
    local status="$(cat /sys/class/power_supply/BAT0/status)"

    if [ "$status" = "Discharging" ]; then
        printf "Bat: %s" "$ratio"
    else
        printf "Cha: %s" "$ratio"
    fi
}

get_wifi () {
    if [ -z "$INTERFACE" ]; then
        printf "(0.0.0.0)"
        return
    fi
    local ssid="$(iw dev "$INTERFACE" info | grep ssid | cut -d ' ' -f 2)"
    local ipv4="$(ip addr show "$INTERFACE" | awk '/inet / {print $2}')"
    printf "%s (%s)" "$ssid" "$ipv4"
}

get_velo () {
    if [ -z "$INTERFACE" ]; then
        printf "Up: 0KBs, Down: 0KBs"
        return
    fi
    local diff_up="$(($NET_CURR_UP - $NET_PREV_UP))"
    local diff_down="$(($NET_CURR_DOWN - $NET_PREV_DOWN))"

    local rate_up=""
    if [ "$diff_up" -lt "1024" ]; then
        rate_up="$diff_up""Bs"
    else
        rate_up="$((diff_up / 1024))""KBs"
    fi

    local rate_down=""
    if [ "$diff_down" -lt "1024" ]; then
        rate_down="$diff_down""Bs"
    else
        rate_down="$((diff_down / 1024))""KBs"
    fi

    printf "Up: %s, Down: %s" "$rate_up" "$rate_down"
}

# Start pa if not already on
#pulseaudio --start

count=0
while [ "1" ]
do

    # Update networking info outside of $(...) since $(...) spawns a subshell
    update_nets

    title="$(get_date)"
    title="$(get_vol)"" | $title"
    title="$(get_bat)"" | $title"
    title="$(get_wifi)"" | $title"
    title="$(get_velo)"" | $title"

    xsetroot -name "$title"

    sleep 1
    count=$((count+1))
done



