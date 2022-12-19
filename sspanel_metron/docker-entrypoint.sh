#!/bin/sh

echo >&2 " _____ _____ _____             _ "
echo >&2 "|   __|   __|  _  |___ ___ ___| |"
echo >&2 "|__   |__   |   __| .'|   | -_| |"
echo >&2 "|_____|_____|__|  |__,|_|_|___|_|"

echo -n >&2 "DB_HOST Set Checking..$DB_HOST"
if [ -z "$DB_HOST" ] && [ -z "$DB_SOCKET" ];then
    echo >&2 "DB_HOST or DB_SOCKET not set!"
fi


echo  >&2 "Pass"
echo -n >&2 "\nChecking if installation exists..."

if [ ! -e public/index.php ]; then
    echo  >&2 "Not found index.php"
    echo -n >&2 "\nCopying new files to directory..."

    if [ -n "$(find -mindepth 1 -maxdepth 1)" ]; then
			echo >&2 "Directory not empty!"
            exit 
	  fi

    cp -r /usr/src/sspanel/SSPanel-Uim/. .

    echo >&2 ".Copy complete"
else
    echo >&2 "..OK"
fi


if [ -n "$DB_HOST" ]; then
    if ! mysql -h $DB_HOST -P $DB_PORT -u $DB_USERNAME --password=$DB_PASSWORD -e "SELECT VERSION()" > /dev/null; then
        echo >&2 "Cannot connect to database!"
    fi
    if ! mysql -h $DB_HOST -P $DB_PORT -u $DB_USERNAME --password=$DB_PASSWORD -e "USE $DB_DATABASE" > /dev/null; then
        echo -n >&2 "\nInitialize database..."
        mysql -h $DB_HOST -P $DB_PORT -u $DB_USERNAME --password=$DB_PASSWORD -e "CREATE DATABASE $DB_DATABASE CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
        chown -R www-data:www-data .
        chmod -R 755 .
	      echo >&2 "CREATE DATABASE"
        php vendor/bin/phinx migrate
        php xcat Tool importAllSettings
        temp_sql_result=$(mysql -h $DB_HOST -P $DB_PORT -u $DB_USERNAME --password=$DB_PASSWORD -e "SELECT user_name FROM $DB_DATABASE.user WHERE user_name = 'admin';")
    else
        echo >&2 "...OK"
    fi
fi

echo -n >&2 "\nChecking if admin account exists..."


if [ -z "$temp_sql_result" ]; then
	echo >&2 "Not found admin_user"
	echo -n >&2 "\nAttemping to create admin account..."
	if [ -z "$SSPANEL_ADMIN_EMAIL" ] || [ -z "$SSPANEL_ADMIN_PASSWORD" ];then
		echo >&2 "SSPANEL_ADMIN_EMAIL or SSPANEL_ADMIN_PASSWORD not set!"
	else
    echo -n >&2 "\n" 
		printf $SSPANEL_ADMIN_EMAIL'\n'$SSPANEL_ADMIN_PASSWORD'\ny\n' | php xcat Tool createAdmin
	fi
fi


echo -n >&2 "\nChecking if client binaries exist..."
if [ ! -d "public/clients" ]; then
	echo >&2 "Not found"
	echo -n >&2 "\nDownloading client binaries...\n\n"
	# php xcat ClientDownload
else
	echo >&2 "Found"
fi


php 

echo >&2 "php-fpm start..."
/usr/local/sbin/php-fpm -D

echo >&2 "nginx  start..."
exec /usr/sbin/nginx -g 'daemon off;'


