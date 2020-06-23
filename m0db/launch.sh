#!/bin/bash

MANGOS_DB_RELEASE="Rel21"
MANGOS_WORLD_DB="mangos0"
MANGOS_CHARACTER_DB="character0"
MANGOS_REALM_DB="realmd"
MANGOS_PASSWORD="mangos"

MYSQL_DATA="/var/lib/mysql"
MYSQLD=mysqld
MYSQL=mysql
MYSQLADMIN=mysqladmin
MYSQL_SSL_SETUP=mysql_ssl_rsa_setup
MYSQL_ROOT_CMD="$MYSQL -u root"
MYSQL_MCMD="$MYSQL -u mangos --password=$MANGOS_PASSWORD"

function quit {
	echo "Error building database"
	kill $1
	exit 1
}

if [ ! -d $MYSQL_DATA/mysql ]; then
	if [ -z $MYSQL_ROOT_PASSWORD ]; then
		echo "Can't create database: MYSQL_ROOT_PASSWORD envvar is missing" >&2
		exit 1
	fi

	$MYSQLD --user=root --initialize-insecure || exit 1
	$MYSQL_SSL_SETUP --datadir=$MYSQL_DATA || exit 2
	$MYSQLD --user=root --skip-networking &
	PID="$!"
	for x in {1..10}; do
		$MYSQL -u root -e '\q'
	    if [ $? -eq 0 ]; then
			break
		else
			sleep 1
		fi
	done
	if [ $x -eq 10 ]; then
		echo "ERROR: Timeout starting MySQL server"
		exit 10
	fi
	$MYSQL -u root < /database/user.sql || quit $PID

	echo "Creating world database..."
	$MYSQL -u root < /database/World/Setup/mangosdCreateDB.sql || quit $PID
	$MYSQL_ROOT_CMD $MANGOS_WORLD_DB < /database/World/Setup/mangosdLoadDB.sql || quit $PID
	for f in /database/World/Setup/FullDB/*.sql; do
		echo $f
		$MYSQL_ROOT_CMD $MANGOS_WORLD_DB < $f || quit $PID
	done
	for f in $(ls -1 /database/World/Updates/$MANGOS_DB_RELEASE/*.sql 2>/dev/null); do
		echo $f
		$MYSQL_ROOT_CMD $MANGOS_WORLD_DB < $f || quit $PID
	done

	echo "Creating character database..."
	$MYSQL -u root < /database/Character/Setup/characterCreateDB.sql || quit $PID
	$MYSQL_ROOT_CMD $MANGOS_CHARACTER_DB < /database/Character/Setup/characterLoadDB.sql || quit $PID
	for f in $(ls -1 /database/Character/Updates/$MANGOS_DB_RELEASE/*.sql 2>/dev/null); do
		echo $f
		$MYSQL_ROOT_CMD $MANGOS_WORLD_DB < $f || quit $PID
	done

	echo "Creating realm database..."
	$MYSQL -u root < /database/Realm/Setup/realmdCreateDB.sql || quit $PID
	$MYSQL_ROOT_CMD $MANGOS_REALM_DB < /database/Realm/Setup/realmdLoadDB.sql || quit $PID
	for f in $(ls -1 /database/Realm/Updates/$MANGOS_DB_RELEASE/*.sql 2>/dev/null); do
		echo $f
		$MYSQL_ROOT_CMD $MANGOS_REALM_DB < $f || quit $PID
	done

	if [ "$LOCALE" = "German" ]; then
		echo "Installing german locales"
		$MYSQL_ROOT_CMD $MANGOS_WORLD_DB < /database/Translations/1_LocaleTablePrepare.sql || quit $PID
		(sed "s/\`help_text_loc0\` VARCHAR(100)/\`help_text_loc0\` VARCHAR(4096)/" < /database/Translations/2_Add_NewLocalisationFields.sql | $MYSQL_ROOT_CMD $MANGOS_WORLD_DB) || quit $PID
		(sed "s/'creature_template'/creature_template/g" /database/Translations/3_InitialSaveEnglish.sql | $MYSQL_ROOT_CMD $MANGOS_WORLD_DB) || quit $PI
		for f in $(ls -1 /database/Translations/Translations/$LOCALE/*.sql 2>/dev/null); do
			echo $f
			$MYSQL_ROOT_CMD $MANGOS_WORLD_DB < $f || quit $PID
		done
	fi

	$MYSQLADMIN -u root password $MYSQL_ROOT_PASSWORD || quit $PID
	
	kill $PID
	wait $PID

	chown -R mysql:mysql $MYSQL_DATA
fi

if [ "$(id -u)" = '0' ]; then
	$@ -u root
else
	$@
fi
