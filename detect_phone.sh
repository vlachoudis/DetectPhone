#!/bin/bash
# author: Vasilis.Vlachoudis@cern.ch
# edited: janis.mezitis86@gmail.com
# version: 0.1
# date: 6 Feb 2012

BTHW="xx:xx:xx:xx:xx:xx"  # Enter your Phone Bluetooth hardware address
LOCKPRG="xscreensaver"	  # Screen saver program/ wont corectly work with xscreensaver
MIN_SIGNAL_STRENGTH=-11	  # Enter min signal strength at which we will do automatic unlock 
SLEEP=2					  # Enter seconds which we sleep after every iteration
TIMEOUT_AFTER_LOCK=30	  # Enter seconds after unlock when we start to do auto unlock
# allow echoing some information (can be used to adjust bluetooth strenght signal, just set this param as true and run script)
DEBUG=false

# calculate PID for locker
PID=$(pgrep -u $USER $LOCKPRG | head -1)

# Method for getting seconds (setted on SEC_AFTER_LOC) after lock event occure
# Possible output for "xscreensaver-command -time"
	#XScreenSaver 5.21: screen non-blanked since Thu Mar 14 22:00:51 2013
	#XScreenSaver 5.21: screen locked since Thu Mar 14 22:01:45 2013
function getSecondsAfterLock() {
	local xsc_event_time=$(xscreensaver-command -time)
	SEC_AFTER_LOC=0
	if [[ "$xsc_event_time" =~ "screen locked since" ]]; then
		SEC_AFTER_LOC=$(expr $(date +%s) - $(echo $xsc_event_time | sed 's/.*since //' | xargs -I {} date -d "{}" +%s))
		test $DEBUG == "true" && echo "SEC AFTER LOCK:$SEC_AFTER_LOC"
	fi
	return 0
}

# get bluetooth signal strenght (less is better)
# we check if bluetooth device is on our connected device list (if not we try to connect)
# signal strength setted on SIGNAL_STR
function getBLSignalStrength() {
	local error=""
	while true; do
		error=""
		if [ -z "$(hcitool con | grep $BTHW)" ]; then
			# need sudo
			# if we arent connected to device then make temporar conection
			error=$(sudo hcitool cc $BTHW 2>&1) # problem is that in case if hcitool return >0, then value of $? is overiden by assign func exit value
		fi
		if [ -z "$error" ]; then
			local rssi=$(hcitool rssi $BTHW 2>&1)
			if [[ "$rssi" =~ "RSSI return value" ]]; then
				SIGNAL_STR="$(echo $rssi | sed 's/[^0-9-]*//')"
				return 0
			fi
		else
			sleep 1
		fi
	done
}


while true
do
	getSecondsAfterLock		# get seconds after lock occures
	# check if lock timeout has expired
	if [ $SEC_AFTER_LOC -gt $TIMEOUT_AFTER_LOCK ]; then
		getBLSignalStrength
		if [ $SIGNAL_STR -gt $MIN_SIGNAL_STRENGTH ]; then
			# Phone present...
			kill -HUP $PID
			xset dpms force on
		fi
	elif [ $DEBUG == "true" ]; then
		getBLSignalStrength && echo "Signal strength:$SIGNAL_STR"
	fi
	sleep $SLEEP
done