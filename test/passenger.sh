#!/usr/bin/env bash

NO_MIRRORS=1
source /vagrant/.sh/base.sh

set-timezone 'Europe/Berlin'
provision passenger

[ -d /vagrant/public ] || mkdir /vagrant/public
echo 'Yay, it works!' > /vagrant/public/index.html

on 3000

wget -qO/dev/null http://localhost:3000
