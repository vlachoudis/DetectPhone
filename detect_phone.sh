#!/bin/bash
# author: Vasilis.Vlachoudis@cern.ch
# version: 0.0
# date: 6 Feb 2012

BTHW="xx:xx:xx:xx:xx:xx"  # Enter your Phone Bluetooth hardware address
LOCKPRG="kscreenlocker"		# Screen saver program
MIN_SIGNAL_STRENGTH=-5	  # Enter min signal strength at which we will do automatic unlock 
SLEEP=5

while true
do	# Run only if screen is locked
	PID=$(pgrep -u $USER $LOCKPRG | head -1)
	if [ .$PID != . ]; then
		# Ping the phone (needs sudo permissions
		# chmod u+s /usr/bin/l2ping
		#l2ping -t 5 -c 1 $BTHW >/dev/null 2>/dev/null
		if [ -z "$(hcitool con | grep $BTHW)" ]; then
			# need sudo
			sudo hcitool cc $BTHW # if we arent connected to device then do temporar conection
		fi

		STR=$(hcitool rssi $BTHW | sed 's/[^0-9-]*//') # get signal signal strength (less is worse)
		echo $STR
		if [ $STR -gt $MIN_SIGNAL_STRENGTH ]; then
			# Phone present...
			kill $PID
			xset dpms force on
		fi
	fi
	sleep $SLEEP
done