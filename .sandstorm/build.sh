#!/bin/bash
# Downloads MediaWiki.

set -euo pipefail

cd /opt/app

# Adjust PHP configuration to use /tmp for sessions, for simplicity.
for php_ini in /etc/php5/cli/php.ini /etc/php5/fpm/php.ini ; do
    sudo chown vagrant "$php_ini"
    if ! grep -q 'session.save_path = "/tmp"' "$php_ini" ; then
        echo 'session.save_path = "/tmp"' >> "$php_ini"
    fi
done

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

# Fetch SemanticBundle if needed.

if [ ! -d /opt/app/extensions/SemanticBundle ] ; then
    wget 'https://docs.google.com/uc?authuser=0&id=0B3i-pfyNssSZVG1DWVNvS3pXS1k&export=download' -O /tmp/bundle.tar.gz
    (cd /opt/app/extensions ; mkdir -p SemanticBundle ; cd SemanticBundle ; tar zxvf /tmp/bundle.tar.gz)
fi
