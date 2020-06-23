#!/bin/bash
if [ ! -f /mangos/etc/mangosd.conf ]; then
	cp /mangos/etc/mangosd.conf.dist2 /mangos/etc/mangosd.conf
        sed -i "s/LOGIN_DATABASE_INFO/$LOGIN_DATABASE_INFO/g" /mangos/etc/mangosd.conf
        sed -i "s/CHARACTER_DATABASE_INFO/$CHARACTER_DATABASE_INFO/g" /mangos/etc/mangosd.conf
        sed -i "s/WORLD_DATABASE_INFO/$WORLD_DATABASE_INFO/g" /mangos/etc/mangosd.conf
fi
/mangos/bin/mangosd -c /mangos/etc/mangosd.conf

