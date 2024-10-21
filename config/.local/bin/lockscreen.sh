#!/bin/bash
##################### WARNING ######################
# i3 lock allows notifications.
# Underlying text can show on asciiquarium.
####################################################

# Mute ALL sound cards
awk '/ \[/ { print $1 }' /proc/asound/cards | \
   while read card
   do
   amixer --quiet -c "$card" sset "$(amixer -c "$card" | head -n 1 | awk -F\' '{ print $2 }')" mute
   done

{
read screen1
read screen2
read screen3
} < <(cat /sys/class/drm/card0-*-1/enabled)

screen=`echo $screen{1,2,3} | tr " " "\n" | grep -c enabled`

if [[ $screen -eq 1 ]]; then
   sakura -s -x asciiquarium 2>/dev/null &
   alock -bg none
   xdotool key --clearmodifiers q
elif [[ $screen -gt 1 ]]; then
   ~/.config/i3/new-lock.sh
fi

