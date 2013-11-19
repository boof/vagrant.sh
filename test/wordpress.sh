#!/usr/bin/env bash

NO_MIRRORS=1
source /vagrant/.sh/base.sh
set-timezone 'Europe/Berlin'

# setup
[ -d /vagrant/wordpress ] && rm -r /vagrant/wordpress

# provision
provision wordpress

# check
[ -d /vagrant/test/wordpress ] || mkdir -p /vagrant/test/wordpress
wget -qO/vagrant/test/wordpress/index.html http://localhost:80
