#!/bin/bash
# author: Vasilis.Vlachoudis@cern.ch
# version 0.1
# date: 6 Feb 2012

BTHW="XX:XX:XX:XX:XX:XX"	# Enter your Phone Bluetooth hardware address
LOCKPRG="kscreenlocker"		# Screen saver program
SLEEP=5				# Enter seconds which we sleep after every iteration

ME=`whoami`
while true
do	# Run only if screen is locked
	PID=$(pgrep -u $ME $LOCKPRG | head -1)
	if [ .$PID != . ]; then
		# Ping the phone needs sudo permissions
		# chmod u+s /usr/bin/l2ping
		l2ping -t 5 -c 1 $BTHW >/dev/null 2>/dev/null
		RC=$?
		if [ $RC = 0 ]; then
			# Phone present...
			kill $PID
			xset dpms force on
		fi
	fi
	sleep $SLEEP
done
