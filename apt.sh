#!/usr/bin/env bash

# checks if a package is installed
function has () {
    dpkg -s "$1" 2>/dev/null | grep 'Status: ' | grep 'installed' >/dev/null
}
# installs packages unattended and w/o output
function apt_install () {
    aptitude install -y "$@" >/dev/null 2>&1
}
# configures apt to use local mirrors
[[ -z "$NO_MIRRORS" ]] && {
    [ -e /etc/apt/sources.list.orig ] && return 0

    cp /etc/apt/sources.list /etc/apt/sources.list.orig

    read -r -d '' APT_SOURCES << 'SOURCES'
deb mirror://mirrors.ubuntu.com/mirrors.txt precise main restricted universe multiverse
deb mirror://mirrors.ubuntu.com/mirrors.txt precise-updates main restricted universe multiverse
deb mirror://mirrors.ubuntu.com/mirrors.txt precise-backports main restricted universe multiverse
deb mirror://mirrors.ubuntu.com/mirrors.txt precise-security main restricted universe multiverse
SOURCES

    echo "$APT_SOURCES" > /etc/apt/sources.list
    touch -d '-3 days' /etc/apt/sources.list
}

# updates the package index
touch -d '-2 days' /var/cache/apt/limit
[ /var/cache/apt/limit -ot /etc/apt/sources.list ] || {
    touch /etc/apt/sources.list

    echo "Updating package index..."
    aptitude update >/dev/null 2>&1
}
