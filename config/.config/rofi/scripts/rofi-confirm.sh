#!/bin/bash

ICON="$1"

CANCEL="No"
CONFIRM="Yes"

case "$(echo -e "$CANCEL\n$CONFIRM" | rofi -dmenu -i -theme ~/.config/rofi/themes/purple.rasi -mesg "$ICON")" in
    "$CANCEL")  exit 1;;
    "$CONFIRM") exit 0;;
     *)         exit 1
esac
