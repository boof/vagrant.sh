#!/usr/bin/env bash

provision apt

has mongodb-10gen || {
    apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 7F0CEB10 >/dev/null
    echo 'deb http://downloads-distro.mongodb.org/repo/ubuntu-upstart dist 10gen' > /etc/apt/sources.list.d/mongodb.list

    aptitude update >/dev/null || exit 1
    apt-install mongodb-10gen
}
