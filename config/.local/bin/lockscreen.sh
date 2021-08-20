#!/bin/bash
##################### WARNING ######################
# i3 lock allows notifications
# Sometimes underlying text is shown on asciiquarium
####################################################
set -e

screen=$(xrandr --listactivemonitors | grep -- "-1" | cut -d " " -f 6)

if [[ $screen = "DP-1" ]] || [[ $screen = "LVDS-1" ]] || [[ $screen = "VGA-1" ]]; then
amixer set Master mute >/dev/null && sakura -s -x asciiquarium 2>/dev/null & alock -bg none; xdotool key --clearmodifiers q

else 
amixer set Master mute >/dev/null && ~/.config/i3/lock.sh

fi
