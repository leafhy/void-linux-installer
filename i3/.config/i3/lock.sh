#!/bin/bash
# https://raw.githubusercontent.com/evelyndooley/dotfiles/master/linux_old/i3/lock.sh
OUTPUT_IMAGE=/tmp/i3lock.png

RESOLUTION=$(xrandr -q | awk -F'current' -F',' 'NR==1 {gsub("( |current)","");print $2}')


ffmpeg -f x11grab -video_size $RESOLUTION -i $DISPLAY -filter_complex "gblur=40, eq=brightness=-.02" -y -vframes 1 $OUTPUT_IMAGE

lock() {
	letterEnteredColor=d23c3dff
	letterRemovedColor=d23c3dff
	passwordCorrect=00000000
	passwordIncorrect=d23c3dff
	background=00000022
	foreground=ffffffff
	i3lock \
		-t -i "$OUTPUT_IMAGE" \
		--timestr="%I:%M %p" \
		--clock --datestr "Type password..." \
		--insidecolor=$background \
		--ringcolor=$foreground \
		--line-uses-inside \
		--keyhlcolor=$letterEnteredColor \
		--bshlcolor=$letterRemovedColor \
		--separatorcolor=$background \
		--insidevercolor=$passwordCorrect \
		--insidewrongcolor=$passwordIncorrect \
		--ringvercolor=$foreground \
		--ringwrongcolor=$foreground  \
	 	--veriftext="" --wrongtext="" \
		--verifcolor="$foreground" \
		--timecolor="$foreground" \
		--datecolor="$foreground" \
        	--noinputtext="" \
		--force-clock
}

lock  

rm $OUTPUT_IMAGE
