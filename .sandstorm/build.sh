#!/bin/bash

# Downloads MediaWiki & dependencies.
#
# FIXME: Verify hashes!

set -euo pipefail

cd /opt/app

# Adjust PHP configuration to use /tmp for sessions, for simplicity.
for php_ini in /etc/php5/cli/php.ini /etc/php5/fpm/php.ini ; do
    sudo chown vagrant "$php_ini"
    if ! grep -q 'session.save_path = "/tmp"' "$php_ini" ; then
        echo 'session.save_path = "/tmp"' >> "$php_ini"
    fi
done

# Remove the images directory if it's a real directory.
if [ ! "$(readlink -f /opt/app/images)" = "$(readlink -f /var/mediawiki-images)" ] ; then
    rm -rf /opt/app/images
    ln -s /var/mediawiki-images /opt/app/images
fi

# Disable gzip to avoid mojibake on nginx errors.
sudo chown vagrant /etc/nginx/nginx.conf
sudo sed -i 's,gzip on;,gzip off;,g' /etc/nginx/nginx.conf

if [ ! -f index.php ] ; then
    wget -c https://github.com/wikimedia/mediawiki/archive/1.25.1.tar.gz -O /tmp/tar.gz
    tar zxvf /tmp/tar.gz --strip-components=1
fi

# Only re-run composer install if composer.phar didn't exist until now.
if [ -f /opt/app/composer.json ] ; then
    if [ ! -f composer.phar ] ; then
        curl -sS https://getcomposer.org/installer | php
        php composer.phar install
    fi
fi

# Fetch Vector theme if needed.
if [ ! -d /opt/app/skins/Vector ] ; then
    wget 'https://git.wikimedia.org/zip/?r=mediawiki/skins/Vector&format=gz' -O /tmp/vector.tar.gz
    (cd /opt/app/skins ; mkdir -p Vector ; cd Vector ; tar zxvf /tmp/vector.tar.gz)
fi

# Fetch SemanticBundle if needed.
if [ ! -f /opt/app/extensions/SemanticBundle/SemanticBundle.php ] ; then
    wget 'https://docs.google.com/uc?authuser=0&id=0B3i-pfyNssSZVG1DWVNvS3pXS1k&export=download' -O /tmp/bundle.tar.gz
    (cd /opt/app/extensions ; tar zxvf /tmp/bundle.tar.gz)
fi
