#!/bin/bash
php5enmod mcrypt
if [ "$TIMEZONE" != "" ]
then
	timezone="${TIMEZONE//\//\\\/}"
	echo "Setting PHP timezone: $TIMEZONE"
	sed -i "s/;date.timezone =.*/date.timezone = $timezone/" /etc/php5/fpm/php.ini
	sed -i "s/;date.timezone =.*/date.timezone = $timezone/" /etc/php5/cli/php.ini
fi

echo " ==> Turning NGINX daemon off"
sed -i "s/;daemonize = yes/daemonize = no/" /etc/php5/fpm/php-fpm.conf

# Turn on display errors
sed -i "s/display_errors = Off/display_errors = On/" /etc/php5/fpm/php.ini
sed -i "s/display_errors = Off/display_errors = On/" /etc/php5/cli/php.ini

if [ "${ENVIRONMENT:0:4}" != "prod" ]
then
	sed -i "s/display_startup_errors = Off/display_startup_errors = On/" /etc/php5/fpm/php.ini
	sed -i "s/display_startup_errors = Off/display_startup_errors = On/" /etc/php5/cli/php.ini
fi

# Disable default mimetype
sed -i "s/default_mimetype =.*/default_mimetype = \"\"/" /etc/php5/fpm/php.ini
sed -i "s/default_mimetype =.*/default_mimetype = \"\"/" /etc/php5/cli/php.ini

if [ -f "/project/php-fpm.ini" ]
then
	ln -sf "/project/php-fpm.ini" /etc/php5/fpm/php.ini
fi

if [ -f "/project/php-cli.ini" ]
then
	ln -sf "/project/php-cli.ini" /etc/php5/cli/php.ini
fi

if [ -f "/project/php-fpm.conf" ]
then
	ln -sf "/project/php-fpm.conf" /etc/php5/fpm/php-fpm.conf
fi

if [ -f "/project/php-fpm-www.conf" ]
then
	cp -f "/project/php-fpm-www.conf" /etc/php5/fpm/pool.d/www.conf
fi

while read -r e
do
	strlen="${#e}"
	if [ "${e:$strlen-1:1}" == "=" ] || [ "$e" == "${e/=/}" ] || [ $strlen -gt 100 ]
	then
		continue
	fi
	
	echo "env[${e/=/] = \"}\"" >> /etc/php5/fpm/pool.d/www.conf
done <<< "$(env)"
