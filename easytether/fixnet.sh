#!/bin/sh

# Version
version=0.06

# A simple script that checks for connectivity (including working DNS resolution)
# If no connectivity, reset tethering
# 
# Requires easytether-usb to be installed and already setup/working
# Manual (one time) setting of the USB device ID of the tether device (TETHERDEV).

# Find the tethering device with lsusb. Example (Samsung/Verizon kids tablet):
# Bus 001 Device 013: ID 04e8:6860 Samsung Electronics Co., Ltd Galaxy (MTP)
TETHERDEV=04e8:6860
# 04e8:6860 is for Samsung's USB identification (both Note 10 and kids tablet) 

# Some highly available website to check (www.google.com is backed by *lots* of servers)
CHECKWWW=www.google.com

# How long before we check again?
SLEEPITOFF=60

while true; do
	while true; do
		# look for USB device
		lsusb | grep $TETHERDEV > /dev/null 

		# make sure there is a device connected before continuing
		if (( $? )); then
			echo "Tethering device not found! Sleeping 5s..."
			sleep 5s
		else
			echo "Tethering device present, continuing with network check..."
			break
		fi
	done

	# command to check for connectivity
	curl --connect-timeout 10 $CHECKWWW > /dev/null 2>&1

	if [ $? != 0 ]; then
		# No internet
		echo "Network down, resetting USB and restarting easytether!" 
		# Reset the USB device
		usbreset $TETHERDEV 
		# Wait a few seconds for device to be ready again
		sleep 5s
		# (re)start easytether-usb to make a connection
		easytether-usb 
	else
		# Internet working
		echo "Network up!" 
	fi
	echo "Sleeping $SLEEPITOFF before rechecking"
	sleep $SLEEPITOFF
done

