#!/bin/bash
##################### WARNING ######################
# i3 lock allows notifications.
# Underlying text can show on asciiquarium.
####################################################
set -e

# Mute ALL sound cards
awk '/ \[/ { print $1 }' /proc/asound/cards | \
   while read card
   do
   amixer --quiet -c "$card" sset "$(amixer -c "$card" | head -n 1 | awk -F\' '{ print $2 }')" mute
   done

{
read screen1
read screen2
} < <(xrandr --listactivemonitors | awk '/-1/ { print $4 }')

screen=$screen1$screen2

if [[ $screen = "DP-1" ]] || [[ $screen = "LVDS-1" ]] || [[ $screen = "VGA-1" ]]; then
    sakura -s -x asciiquarium 2>/dev/null & alock -bg none; xdotool key --clearmodifiers q

elif [[ $screen1 ]] && [[ $screen2 ]]; then
    ~/.config/i3/new-lock.sh
fi
