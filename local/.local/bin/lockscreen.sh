#!/bin/bash
set -e

DP1=$(xrandr | grep DP-1 | cut -d 9 -f 1 | sed -e 's/[1-9]\+$//' | cut -d "(" -f 1 | cut -d " " -f 2)

if [[ $DP1 = "connected" ]]; then
amixer set Master mute && ~/.config/i3/lock.sh
else
amixer set Master mute && sakura -s -x asciiquarium & alock -bg none; xdotool key --clearmodifiers q
fi
