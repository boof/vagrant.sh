# setup apache to work with WordPress
has libapache2-mod-php5 php5-mysql php5-gd || {
    echo "Setting up WordPress CMS..."
    apt_install libapache2-mod-php5 php5-mysql php5-gd

    [ -f /etc/apache2/sites-available/default.orig ] || {
        sed -i.orig 's/AllowOverride None/AllowOverride FileInfo Options/g' \
            /etc/apache2/sites-available/default
    }
    a2enmod rewrite >/dev/null

    service apache2 restart >/dev/null 2>&1
}

# TODO change the database config in /vagrant/**/wp-config.php
