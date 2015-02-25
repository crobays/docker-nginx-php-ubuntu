#!/bin/bash

if grep -Fxq "daemon off;" /etc/nginx/nginx.conf # The exit status is 0 (true) if the name was found, 1 (false) if not
then
	echo " ==> NGINX daemon already turned off"
else
	echo " ==> Turning NGINX daemon off"
	echo "daemon off;" >> /etc/nginx/nginx.conf
fi

rm -rf /var/log/nginx
mkdir /var/log/nginx

if [ -f "/project/nginx.conf" ]
then
	ln -sf "/project/nginx.conf" /etc/nginx/nginx.conf
fi

file="/conf/nginx-virtual.conf"
if [ -f "/project/$NGINX_CONF" ]
then
	file="/project/$NGINX_CONF"
fi
rm -rf /etc/nginx/sites-enabled/*
cp -f "$file" /etc/nginx/sites-enabled/virtual.conf

if [ "$PUBLIC_PATH" ]
then
	mkdir -p "$PUBLIC_PATH"

	if [ ! -f "$PUBLIC_PATH/index.php" ]
	then
		echo " ==> Creating index.php in $PUBLIC_PATH"
		echo "<h1>You are running $PUBLIC_PATH/index.php on NGINX-PHP on Docker!</h1>" > "$PUBLIC_PATH/index.php"
	fi
	echo " ==> Pointing NGINX to $PUBLIC_PATH"
	sed -i "s/root \/project\/public;/root ${PUBLIC_PATH//\//\\\/};/" /etc/nginx/sites-enabled/virtual.conf
fi

php_code="echo '('.(array_key_exists('DOMAIN',\$_SERVER) ? str_replace('.', '\\\\\.', implode('|', array_unique(array_map(function(\$domain){\$d = array_reverse(explode('.', \$domain)); return \$d[1].'.'.\$d[0];}, in_array(substr(\$_SERVER['DOMAIN'], 0, 1), array('[', '{')) ? json_decode(str_replace(\"'\", '\"', \$_SERVER['DOMAIN']), 1) : array(\$_SERVER['DOMAIN']))))) : '').')';"
domain="$(php -r "$php_code")"

if [ "$domain" == "()" ]
then
	echo " ==> NOT using Access-Control-Allow-Origin headers"
	php_code="file_put_contents('/etc/nginx/conf.d/virtual.conf', preg_replace('/# == add header ==(.|\n)*# == add header ==/', '', file_get_contents('/etc/nginx/conf.d/virtual.conf')));"
	php -r "$php_code"
elif [ "$domain" ]
then
	echo " ==> Using Access-Control-Allow-Origin headers for $domain"
	sed -i "s/example\\\.com/$domain/" /etc/nginx/conf.d/virtual.conf
fi

echo "PUBLIC_PATH: $PUBLIC_PATH"
