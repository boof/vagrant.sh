#!/usr/bin/env bash

provision apt
provides database

function create-db-user () {
    local username=${1}
    local password=${2:-$username}
    mysql "CREATE USER '${username}'@'localhost' IDENTIFIED BY '${password}';"
}
function create-db () {
    local db=${1}
    local user=${2:-vagrant}
    mysql \
<<SQL
    CREATE DATABASE IF NOT EXISTS ${db} CHARACTER SET utf8;
    GRANT ALL PRIVILEGES ON ${db}.* TO '${user}'@'localhost' IDENTIFIED BY '${user}';
SQL
}

# setup mysql-server to work well with vagrant
has mysql-server-5.5 || {
    echo "Setting up MySQL server..."

    echo 'mysql-server-5.5 mysql-server/root_password password root' \
    | debconf-set-selections
    echo 'mysql-server-5.5 mysql-server/root_password_again password root' \
    | debconf-set-selections
    apt-install mysql-server-5.5

    echo '[client]'       > ~/.my.cnf
    echo 'user=root'     >> ~/.my.cnf
    echo 'password=root' >> ~/.my.cnf
    chmod 600 ~/.my.cnf

    create-db vagrant
    create-db-user vagrant

    echo '[client]'          > /home/vagrant/.my.cnf
    echo 'user=vagrant'     >> /home/vagrant/.my.cnf
    echo 'password=vagrant' >> /home/vagrant/.my.cnf
    chown vagrant:vagrant /home/vagrant/.my.cnf
    chmod 600 /home/vagrant/.my.cnf

}
