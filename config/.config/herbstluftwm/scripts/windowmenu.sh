#!/usr/bin/env bash
set -ex
#
# dependencies:
#
#   - rofi

# offer a window menu offering possible actions on that window like
# moving to a different tag or toggling its fullscreen state

action_list() {
    local a="$1"
    "$a" "Close" herbstclient close
    "$a" "Toggle fullscreen" herbstclient fullscreen toggle
    "$a" "Toggle pseudotile" herbstclient pseudotile toggle
    for tag in $(herbstclient complete 1 move) ; do
        "$a" "Move to tag $tag" herbstclient move "$tag"
    done
}

print_menu() {
    echo "$1"
}

title=$(herbstclient attr clients.focus.title)
title=${title//&/&amp;}
rofiflags=(
    -p "herbstclient:"
    -mesg "<i>$title</i>"
    -columns 3
    -location 0
    -width 100
    -no-custom
    -yoffset -10
)
result=$(action_list print_menu | rofi -i -dmenu -m -1 "${rofiflags[@]}")
[ $? -ne 0 ] && exit 0

exec_entry() {
    if [ "$1" = "$result" ] ; then
        shift
        "$@"
        exit 0
    fi
}

action_list exec_entry

