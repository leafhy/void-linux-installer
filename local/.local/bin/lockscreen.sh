#!/bin/bash
set -e

screen=$(xrandr --listactivemonitors | grep -- "-1" | cut -d " " -f 6)

if [[ $screen = "DP-1" ]] || [[ $screen = "LVDS-1" ]] || [[ $screen = "VGA-1" ]]; then
amixer set Master mute && sakura -s -x asciiquarium & alock -bg none; xdotool key --clearmodifiers q

else 
amixer set Master mute && ~/.config/i3/lock.sh

fi
