FROM ubuntu:trusty
ENV HOME /root
# RUN /etc/my_init.d/00_regen_ssh_host_keys.sh
CMD ["/sbin/my_init"]

MAINTAINER Crobays <crobays@userex.nl>
ENV DOCKER_NAME nginx-php
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && \
	apt-get -y dist-upgrade && \
	apt-get install -y software-properties-common && \
	add-apt-repository -y ppa:nginx/stable && \
	apt-get update

RUN apt-get install -y \
	vim \
	curl \
	wget \
	nginx \
	php5-cli \
	php5-fpm \
	php5-mysql \
	php5-pgsql \
	php5-sqlite \
	php5-curl \
	php5-gd \
	php5-mcrypt \
	php5-memcache \
	php5-intl \
	php5-imap \
	php5-tidy \
	supervisor

# Exposed ENV
ENV TIMEZONE Etc/UTC
ENV ENVIRONMENT prod
ENV PUBLIC_PATH /project/public
ENV NGINX_CONF nginx-virtual.conf

VOLUME  ["/project"]
WORKDIR /project

# HTTP ports
EXPOSE 80 443

RUN echo '/sbin/my_init' > /root/.bash_history

RUN mkdir -p /etc/service/nginx && echo "#!/bin/bash\nnginx" > /etc/service/nginx/run
RUN mkdir -p /etc/service/php && echo "#!/bin/bash\nphp5-fpm -c /etc/php5/fpm" > /etc/service/php/run

RUN mkdir -p /etc/my_init.d && echo "#!/bin/bash\necho \"\$TIMEZONE\" > /etc/timezone && dpkg-reconfigure -f noninteractive tzdata" > /etc/my_init.d/01-timezone.sh
ADD /scripts/nginx-config.sh /etc/my_init.d/02-nginx-config.sh
ADD /scripts/php-config.sh /etc/my_init.d/03-php-config.sh
ADD /scripts/my_init /sbin/my_init

RUN chmod +x /etc/my_init.d/* && chmod +x /etc/service/*/run && chmod +x /sbin/my_init

# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ADD /conf /conf

# docker build \
#   -t crobays/nginx-php-ubuntu \
#   /workspace/docker/crobays/nginx-php-ubuntu && \
# docker run \
#   -v /workspace/projects/maikelvlasman/stats-maikelvlasman-com:/project \
#   -p 81:80 \
#   -e ENVIRONMENT=local \
#   -e TIMEZONE=Europe/Amsterdam \
#   -it --rm \
#   --name backend-ubuntu \
#   crobays/nginx-php-ubuntu bash

# docker run \
#   -v /workspace/projects/maikelvlasman/stats-maikelvlasman-com:/project \
#   -p 82:80 \
#   -e ENVIRONMENT=local \
#   -e TIMEZONE=Europe/Amsterdam \
#   -it --rm \
#   --name backend-baseimage \
#   crobays/nginx-php bash

# docker run \
#   -v /workspace/projects/userx/crane-userx-nl:/project \
#   -p 32254:80 \
#   -e PUBLIC_PATH=/project/assets \
#   -e DOMAIN=assets-crane.dev.userx.nl \
#   -e ENVIRONMENT=local \
#   -e TIMEZONE=Europe/Amsterdam \
#   -it --rm \
#   --name assets \
#   crobays/nginx-php-ubuntu bash

# /etc/my_init.d/01-timezone.sh ;/etc/my_init.d/02-conf-log.sh ;/etc/my_init.d/03-nginx-config.sh;/etc/my_init.d/04-php-config.sh


