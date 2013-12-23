#!/usr/bin/env bash

provision apt

# setup apache to work well with vagrant
function setup-apache () {
    local mpm=${1:-worker}

    set-docroot ${2:-/vagrant/public}
    has apache2-mpm-$mpm || {
        echo "Setting up Apache HTTP server... "
        apt-install apache2-mpm-$mpm

        [ -f /etc/apache2/envvars.orig ] || {
            sed -i.orig "s/USER=www-data/USER=${user}/;s/GROUP=www-data/GROUP=${group}/" \
                /etc/apache2/envvars
            chown -R $user:$group /var/log/apache2 /var/lock/apache2
        }
        # suppress warnings
        [ -f /etc/apache2/conf.d/hostname ] || {
            echo "ServerName vagrant" > /etc/apache2/conf.d/hostname
        }

        service apache2 restart >/dev/null
    }
}

function set-docroot () {
    local docroot=${1}

    echo "Setting DOCROOT to ${docroot}..."

    rm -rf /var/www
    [ -d $docroot ] && mkdir -p $docroot
    ln -s $docroot /var/www
}

function setup_apache () {
    echo "setup_apache is deprecated, use setup-apache instead." >&2
    setup-apache $@
}
