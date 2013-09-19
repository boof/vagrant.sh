# setup apache to work well with vagrant
has apache2 || {
    echo "Setting up Apache HTTP server..."
    apt_install apache2

    [ -f /etc/apache2/envvars.orig ] || {
        cp /etc/apache2/envvars /etc/apache2/envvars.orig

        truncate -s 0 /etc/apache2/envvars
        cat /etc/apache2/envvars.orig \
            | sed 's/=www-data/=vagrant/g' \
            >> /etc/apache2/envvars

        chown -R vagrant:vagrant /var/log/apache2 /var/lock/apache2
    }

    rm -rf /var/www
    ln -sf /vagrant /var/www

    service apache2 restart >/dev/null 2>&1
}
