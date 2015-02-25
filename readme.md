## Run NGINX in a container with PHP-FPM on top of Ubuntu:Trusty

	docker build \
		 --tag crobays/nginx-php-ubuntu \
		 .

	docker run \
		-v ./:/project \
		-e PUBLIC_PATH=/project/public \
		-e TIMEZONE=Europe/Amsterdam \
		-e TIMEZONE=Etc/UTC \
		-e ENVIRONMENT=prod \
		-e USER=admin \
		-e PASS=secret \
		-e DATABASE=default \
		-e SQL_DUMP_FILE=your-sql-dump.sql \
		-it --rm \
		crobays/nginx-php-ubuntu
