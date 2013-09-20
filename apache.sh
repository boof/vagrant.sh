# setup apache to work well with vagrant
function setup_apache () {
    local mpm=${1:-worker}
    has apache2-mpm-$mpm || {
        echo "Setting up Apache HTTP server... "
        apt_install apache2-mpm-$mpm

        [ -f /etc/apache2/envvars.orig ] || {
            sed -i.orig "s/USER=www-data/USER=${user}/;s/GROUP=www-data/GROUP=${group}/" \
                /etc/apache2/envvars
            chown -R $user:$group /var/log/apache2 /var/lock/apache2
        }

        rm -rf /var/www
        ln -sf /vagrant /var/www

        service apache2 restart >/dev/null
    }
}

[[ -z "${MPM}" ]] || setup_apache $MPM
