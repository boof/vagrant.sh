#!/usr/bin/env bash

provision apt ruby

function install-passenger () {
    echo 'Setting up Passenger Standalone...'
    gpg --keyserver keyserver.ubuntu.com --recv-keys 561F9B9CAC40B2F7 >/dev/null
    gpg --armor --export 561F9B9CAC40B2F7 | sudo apt-key add - >/dev/null

    apt-install apt-transport-https

    echo 'deb https://oss-binaries.phusionpassenger.com/apt/passenger precise main' > /etc/apt/sources.list.d/passenger.list
    aptitude update >/dev/null || exit 1

    apt-install passenger
}

function on () {
    local port=${1:-3000}
    local directory=`readlink -f ${2:-/vagrant}`
    local pidfile="${directory}/tmp/pids/passenger.${port}.pid"
    local logfile="${directory}/log/passenger.${port}.log"

    can passenger || install-passenger
    # install-bundle $directory

    passenger status --pid-file "${pidfile}" | grep 'is running' >/dev/null && {
        touch $directory/tmp/restart.txt
    } || {
        passenger start "${directory}" --daemonize \
            --pid-file "${pidfile}" --log-file "${logfile}" \
            --port $port --user $user
    }
}
