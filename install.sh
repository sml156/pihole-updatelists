#!/bin/bash

if [[ $(/usr/bin/id -u) -ne 0 ]]; then
	exec sudo -- "$0" "$@"
	exit
fi

[ -d "/etc/pihole" ] && [ -d "/opt/pihole" ] || { echo "Pi-hole doesn't seem to be installed."; exit 1; }
command -v curl >/dev/null 2>&1 || { echo "This script requires cURL to run, install it with 'sudo apt install curl'."; exit 1; }

SPATH=$(dirname $0)
REMOTE_URL=https://raw.githubusercontent.com/jacklul/pihole-updatelists/master

if [ -f "$SPATH/pihole-updatelists.sh" ] && [ -f "$SPATH/pihole-updatelists.conf" ] && [ -f "$SPATH/pihole-updatelists.service" ] && [ -f "$SPATH/pihole-updatelists.timer" ]; then
	cp -v $SPATH/pihole-updatelists.sh /usr/local/sbin/pihole-updatelists && \
	chmod +x /usr/local/sbin/pihole-updatelists
	
	if [ ! -f "/etc/pihole-updatelists.conf" ]; then
		cp -v $SPATH/pihole-updatelists.conf /etc/pihole-updatelists.conf
	fi
	
	cp -v $SPATH/pihole-updatelists.service /etc/systemd/system
	cp -v $SPATH/pihole-updatelists.timer /etc/systemd/system
elif [ "$REMOTE_URL" != "" ]; then
	wget -nv -O /usr/local/sbin/pihole-updatelists "$REMOTE_URL/pihole-updatelists.sh" && \
	chmod +x /usr/local/sbin/pihole-updatelists
	
	if [ ! -f "/etc/pihole-updatelists.conf" ]; then
		wget -nv -O /etc/pihole-updatelists.conf "$REMOTE_URL/pihole-updatelists.conf"
	fi
	
	wget -nv -O /etc/systemd/system/pihole-updatelists.service "$REMOTE_URL/pihole-updatelists.service"
	wget -nv -O /etc/systemd/system/pihole-updatelists.timer "$REMOTE_URL/pihole-updatelists.timer"
else
	exit 1
fi

echo "Enabling and starting pihole-updatelists.timer..."
systemctl enable pihole-updatelists.timer && systemctl start pihole-updatelists.timer
