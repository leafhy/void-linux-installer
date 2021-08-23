LOCK=" Lock"
SLEEP="鈴 Suspend"
LOGOUT="  Logout"
RESTART="  Restart"
SHUTDOWN="  Shutdown"

list_icons() {
    echo $LOCK
    echo $SLEEP
    echo $LOGOUT
    echo $RESTART
    echo $SHUTDOWN
}



     SELECTION="$(list_icons | rofi -dmenu -theme ~/.config/rofi/hlwm-powermenu.rasi)"


case "$SELECTION" in
    
    "$SHUTDOWN")
        ~/.config/rofi/scripts/rofi-confirm.sh 'Shutdown?' && dbus-send --system --print-reply --dest=org.freedesktop.login1 /org/freedesktop/login1 "org.freedesktop.login1.Manager.PowerOff" boolean:true
        ;;

    "$RESTART")
        ~/.config/rofi/scripts/rofi-confirm.sh 'Reboot?' && dbus-send --system --print-reply --dest=org.freedesktop.login1 /org/freedesktop/login1 "org.freedesktop.login1.Manager.Reboot" boolean:true
        ;;

    "$LOCK")
        ~/.config/rofi/scripts/rofi-confirm.sh 'Lock Screen?' && ~/.local/bin/lockscreen.sh
        ;;

    "$SLEEP")
        ~/.config/rofi/scripts/rofi-confirm.sh 'Sleep?' && ~/.config/i3/lock.sh &&  dbus-send --system --print-reply --dest=org.freedesktop.login1 /org/freedesktop/login1 "org.freedesktop.login1.Manager.Suspend" boolean:true
        ;;

    "$LOGOUT")
        /sbin/herbstclient quit
        ;;

    *) exit 1 ;;
esac
