#!/bin/bash
# author: Vasilis.Vlachoudis@cern.ch
# version 0.2
# date: 6 Feb 2012

BTHW="XX:XX:XX:XX:XX:XX"	# Enter your Phone Bluetooth hardware address
DESKTOP="x11"			# Enter desktop/screen saver to check
SLEEP=5				# Enter seconds which we sleep after every iteration
ME=`whoami`

# xscreensaver state
xscreensaver_state() {
	local xtime=$(xscreensaver-command -time)
	if [[ $xtime == *"screen locked"* ]]; then
		LOCKED=1
	else
		LOCKED=0
	fi
}

# kill xscreensaver and restart in unlocked state
xscreensaver_kill() {
	pkill -u $ME xscreensaver
	xscreensaver -nosplash & disown
}

# return kscreenlocker state
kscreenlocker_state() {
	local pid=$(pgrep -u $ME kscreenlocker | head -1)
	if [ .$pid != . ]; then
		LOCKED=1
	else
		LOCKED=0
	fi
}

# kill kscreenlocker
kscreenlocker_kill() {
	pkill -u $ME kscreenlocker
}

# return gnome_screensaver state
gnome_screensaver_state() {
	# Maybe I didn't try it!
	local pid=$(pgrep -u $ME gnome-screensaver | head -1)
	if [ .$pid != . ]; then
		LOCKED=1
	else
		LOCKED=0
	fi
	LOCKED = 0
}

# kill gnome_screensaver
gnome_screensaver_kill() {
	pkill -u $ME gnome-screensaver
}

case "$DESKTOP" in
	"gnome" | "GNOME")
		STATE_CMD=gnome_screensaver_state
		KILL_CMD=gnome_screensaver_kill
		;;
	"kde" | "KDE")
		STATE_CMD=kscreenlocker_state
		KILL_CMD=kscreenlocker_kill
		;;
	*)
		STATE_CMD=xscreensaver_state
		KILL_CMD=xscreensaver_kill
		;;
esac

while true
do	# Run only if screen is locked
	$STATE_CMD
	#PID=$(pgrep -u $ME $LOCKPRG | head -1)
	if [ $LOCKED == 1 ]; then
		# Ping the phone needs sudo permissions
		# chmod u+s /usr/bin/l2ping
		l2ping -t 5 -c 1 $BTHW >/dev/null 2>/dev/null
		RC=$?
		if [ $RC = 0 ]; then
			# Phone present...
			$KILL_CMD
			xset dpms force on
		fi
	fi
	sleep $SLEEP
done
