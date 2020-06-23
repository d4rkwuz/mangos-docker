#!/bin/bash
if [ ! -f /mangos/etc/realmd.conf ]; then
	cp /mangos/etc/realmd.conf.dist2 /mangos/etc/realmd.conf
	sed -i "s/LOGIN_DATABASE_INFO/$LOGIN_DATABASE_INFO/g" /mangos/etc/realmd.conf
fi
/mangos/bin/realmd -c /mangos/etc/realmd.conf

