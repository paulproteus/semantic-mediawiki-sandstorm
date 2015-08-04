#!/bin/bash

# Create a bunch of folders under the clean /var that php, nginx, and mysql expect to exist
mkdir -p /var/lib/nginx
mkdir -p /var/log
mkdir -p /var/log/nginx

# Make /var/mediawiki-cache since we configured MW to store some cache
# files here.
mkdir -p /var/mediawiki-cache

# If the database does not exist, create it from a basically empty
# one.
mkdir -p /var/mediawiki-db
if [ ! -f /var/mediawiki-db/my_wiki.sqlite ] ; then
    cp /opt/app/wiki.sqlite /var/mediawiki-db/my_wiki.sqlite
    # Run migrations. For now, only at wiki creation.
    (cd /opt/app ; php maintenance/update.php --quick )
fi

# Wipe /var/run, since pidfiles and socket files from previous launches should go away
# TODO someday: I'd prefer a tmpfs for these.
rm -rf /var/run
mkdir -p /var/run

# Spawn mysqld, php
/usr/sbin/php5-fpm --nodaemonize --fpm-config /etc/php5/fpm/php-fpm.conf &
# Wait until mysql and php have bound their sockets, indicating readiness
while [ ! -e /var/run/php5-fpm.sock ] ; do
    echo "waiting for php5-fpm to be available at /var/run/php5-fpm.sock"
    sleep .2
done

# Start nginx.
/usr/sbin/nginx -g "daemon off;"
