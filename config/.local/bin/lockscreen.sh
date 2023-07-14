#!/bin/bash
##################### WARNING ######################
# i3 lock allows notifications
# Underlying text can show on asciiquarium
####################################################
set -e

# Mute ALL sound cards
grep ' \[' /proc/asound/cards | cut -d ' ' -f 2 | \
   while read card
   do
   amixer --quiet -c "$card" sset "$(amixer -c "$card" | head -n 1 | awk -F\' '{ print $2 }')" mute
done

screen=$(xrandr --listactivemonitors | grep -- "-1" | cut -d " " -f 6)

if [[ $screen = "DP-1" ]] || [[ $screen = "LVDS-1" ]] || [[ $screen = "VGA-1" ]]; then
    sakura -s -x asciiquarium 2>/dev/null & alock -bg none; xdotool key --clearmodifiers q
else
    ~/.config/i3/new-lock.sh
fi
