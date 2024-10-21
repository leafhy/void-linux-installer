#!/bin/bash
# https://raw.githubusercontent.com/evelyndooley/dotfiles/master/linux_old/i3/lock.sh
# requires i3lock-color >2.13.c.3 due to additions of hyphens in options

OUTPUT_IMAGE=/tmp/i3lock.png

RESOLUTION=$(xrandr -q | awk -F'current' -F',' 'NR==1 {gsub("( |current)","");print $2}')

amixer set Master mute >/dev/null

ffmpeg -f x11grab -video_size $RESOLUTION -i $DISPLAY -filter_complex "gblur=40, eq=brightness=-.02" -y -vframes 1 $OUTPUT_IMAGE 2>/dev/null

lock() {
        letterEnteredColor=d23c3dff
        letterRemovedColor=d23c3dff
        passwordCorrect=00000000
        passwordIncorrect=d23c3dff
        background=00000022
        foreground=ffffffff
        i3lock \
                -t -i "$OUTPUT_IMAGE" \
                --time-str="%H:%M" \
                --clock \
                --date-str "Type password...[Enter]" \
                --inside-color=$background \
                --ring-color=$foreground \
                --line-uses-inside \
                --keyhl-color=$letterEnteredColor \
                --bshl-color=$letterRemovedColor \
                --separator-color=$background \
                --insidever-color=$passwordCorrect \
                --insidewrong-color=$passwordIncorrect \
                --ringver-color=$foreground \
                --ringwrong-color=$foreground  \
                --verif-text="" \
                --wrong-text="" \
                --verif-color="$foreground" \
                --time-color="$foreground" \
                --date-color="$foreground" \
                --noinput-text="" \
                --force-clock
}

lock

rm $OUTPUT_IMAGE
