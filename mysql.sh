#!/usr/bin/env bash

provision apt

# setup mysql-server to work well with vagrant
has mysql-server-5.5 || {
    echo "Setting up MySQL server..."

    echo 'mysql-server-5.5 mysql-server/root_password password root' \
        | debconf-set-selections
    echo 'mysql-server-5.5 mysql-server/root_password_again password root' \
        | debconf-set-selections
    apt_install mysql-server-5.5

    echo '[client]'       > ~/.my.cnf
    echo 'user=root'     >> ~/.my.cnf
    echo 'password=root' >> ~/.my.cnf
    chmod 600 ~/.my.cnf

    mysql \
<<SQL
    CREATE DATABASE IF NOT EXISTS vagrant CHARACTER SET utf8;
    CREATE USER 'vagrant'@'localhost' IDENTIFIED BY 'vagrant';
    GRANT ALL PRIVILEGES ON vagrant.* TO 'vagrant'@'localhost' IDENTIFIED BY 'vagrant';
SQL

    echo '[client]'          > /home/vagrant/.my.cnf
    echo 'user=vagrant'     >> /home/vagrant/.my.cnf
    echo 'password=vagrant' >> /home/vagrant/.my.cnf
    chown vagrant:vagrant /home/vagrant/.my.cnf
    chmod 600 /home/vagrant/.my.cnf

}
