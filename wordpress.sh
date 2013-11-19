#!/usr/bin/env bash

MPM=prefork provision apt apache mysql

config=`find /vagrant -name 'wp-config.php' -print -quit`
if [[ -z "$config" ]]; then
    echo "Deploying WordPress installation..."

    local TMPDIR=`mktemp --directory`

    wget --quiet --no-http-keep-alive -O - 'http://wordpress.org/latest.tar.gz' \
        | tar -C $TMPDIR -xzf -

    local SOURCE="${TMPDIR}/wordpress"
    local DEST="/vagrant/wordpress"

    # fix line endings and create config file
    tr -d '\r' < $SOURCE/wp-config-sample.php > $SOURCE/wp-config.php
    config=$SOURCE/wp-config.php

    # add correct salts
    salts=$TMPDIR/salts
    wget --quiet -O $salts 'https://api.wordpress.org/secret-key/1.1/salt/'
    sed -i "
    \_/\*\*#@+_,\_/\*\*#@-\*/_ {
        \_/\*\*#@-\*/_ r ${salts}
        d
    }" $config

    mkdir $DEST 2>/dev/null
    cp -r $SOURCE/* $DEST
    config=$DEST/wp-config.php
    rm -r $TMPDIR
fi

[ -f "${config}.orig" ] || {
    echo "Configuring WordPress installation..."
    cp $config $config.orig
    sed -ri "s/\('DB_NAME',[^)]+\)/('DB_NAME', 'vagrant')/" $config
    sed -ri "s/\('DB_USER',[^)]+\)/('DB_USER', 'vagrant')/" $config
    sed -ri "s/\('DB_PASSWORD',[^)]+\)/('DB_PASSWORD', 'vagrant')/" $config
    sed -ri "s/\('DB_HOST',[^)]+\)/('DB_HOST', 'localhost')/" $config
    sed -ri "s/\('DB_CHARSET',[^)]+\)/('DB_CHARSET', 'utf8')/" $config
}

# setup apache to work with WordPress
has libapache2-mod-php5 php5-mysql php5-gd || {
    echo "Setting up WordPress requirements..."
    apt-install libapache2-mod-php5 php5-mysql php5-gd

    site=/etc/apache2/sites-available/default
    [ -f $site.orig ] || {
        cp $site $site.orig
        sed -i "s/\/var\/www/$(dirname $config | sed -e 's/[]\/()$*.^|[]/\\&/g')/g" $site
        sed -i 's/AllowOverride None/AllowOverride FileInfo Options/g' $site
    }
    a2enmod rewrite >/dev/null
}

service apache2 restart >/dev/null
