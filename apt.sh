#!/usr/bin/env bash

# checks if a package is installed
function has () {
    dpkg -s "$1" >/dev/null 2>&1
}

# installs packages unattended and w/o output
function apt-install () {
    echo "+ $@"
    aptitude install -y "$@" >/dev/null || exit 1
}

function apt-update () {
    echo "Updating package index..."
    touch /var/cache/apt/limit
    apt-get update >/dev/null || exit 1
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
}

# updates the package index
[ -f /var/cache/apt/limit ] && [ /var/cache/apt/limit -nt /etc/apt/sources.list ] || apt-update
