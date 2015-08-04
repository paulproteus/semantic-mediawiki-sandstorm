#!/bin/bash
# Downloads MediaWiki.

set -eu

cd /opt/app
if [ ! -f index.php ] ; then
    wget -c https://github.com/wikimedia/mediawiki/archive/1.25.1.tar.gz -O /tmp/tar.gz
    tar --strip-components=1 zxvf /tmp/tar.gz
fi

if [ -f /opt/app/composer.json ] ; then
    if [ ! -f composer.phar ] ; then
        curl -sS https://getcomposer.org/installer | php
    fi
    php composer.phar install
fi
