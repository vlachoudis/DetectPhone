#!/bin/bash
# author: Vasilis.Vlachoudis@cern.ch
# version 0.3
# date: 12 Dec 2016

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
kscreenlocker4_state() {
	local pid=$(pgrep -u $ME kscreenlocker | head -1)
	if [ .$pid != . ]; then
		LOCKED=1
	else
		LOCKED=0
	fi
}

# kill kscreenlocker
kscreenlocker4_kill() {
	qdbus  | grep kscreenlocker_greet | xargs -I {} qdbus {} /MainApplication quit
#	pkill -u $ME kscreenlocker
}

# return kscreenlocker state
kscreenlocker5_state() {
	local active=$(qdbus org.freedesktop.ScreenSaver /ScreenSaver GetActive)
	if [ $active = true ]; then
		LOCKED=1
	else
		LOCKED=0
	fi
}

# kill kscreenlocker
kscreenlocker5_kill() {
	loginctl unlock-session
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
	"kde4" | "KDE4")
		STATE_CMD=kscreenlocker4_state
		KILL_CMD=kscreenlocker4_kill
		;;
	"kde" | "KDE" | "kde5" | "KDE5")
		STATE_CMD=kscreenlocker5_state
		KILL_CMD=kscreenlocker5_kill
		;;
	"x" | "X"|"x11"|"X11")
		STATE_CMD=xscreensaver_state
		KILL_CMD=xscreensaver_kill
		;;
	*)
		echo "Unknown DESKTOP specified"
		exit -1
esac

while true
do	# Run only if screen is locked
	$STATE_CMD
	#echo "LOCKED=$LOCKED"
	if [ $LOCKED == 1 ]; then
		# Ping the phone needs sudo permissions
		# chmod u+s /usr/bin/l2ping
		l2ping -t 5 -c 1 $BTHW >/dev/null 2>/dev/null
		RC=$?
		#echo "RC=$RC"
		if [ $RC = 0 ]; then
			# Phone present...
			#echo "KILL"
			$KILL_CMD
			xset dpms force on
		fi
	fi
	sleep $SLEEP
done
