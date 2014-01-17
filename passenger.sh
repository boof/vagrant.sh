#!/usr/bin/env bash

provides rack
provision apt ruby build

# TODO create service
function rackup-on () {
    local port=${1:-3000}
    local directory=`readlink -f ${2:-/vagrant}`
    local config="$directory/passenger-standalone.json"
    local pidfile="/var/run/passenger/$(basename $directory).pid"

    # configure unicorn
    [ -e $config ] || {
        cp "$DIR/contrib/passenger-standalone.json" $config
    }
    sed -i "s/\"port\": 3000/\"port\": $port/" $config

    # (re)start passenger
    [ -e $pidfile ] && passenger-status `cat $pidfile` >/dev/null && {
        touch "${directory}/tmp/restart.txt" && return 0
    } || {
        local logdir="${directory}/log"
        local logfile="${logdir}/passenger.log"
        local gemfile="$directory/Gemfile"

        local start="passenger start ${directory}"
        start="$start --daemonize --pid-file ${pidfile} --log-file ${logfile}"
        start="$start --port $port --user $user"

        [ -d $logdir ] || {
            mkdir $logdir
            chown -R $user:$group $logdir
        }

        if [ -e $gemfile ];
        then
            install-bundle $directory
            BUNDLE_GEMFILE=$gemfile as $user "bundle exec $start" && return 0
        else
            as $user $start && return 0
        fi
    }
}

# create directory
[ -d /var/run/passenger ] || {
    mkdir /var/run/passenger
    chown -R $user:$group /var/run/passenger
}

[ -e /etc/apt/sources.list.d/passenger.list ] || {
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 561F9B9CAC40B2F7 >/dev/null
    apt-install apt-transport-https ca-certificates

    echo 'deb https://oss-binaries.phusionpassenger.com/apt/passenger precise main' > \
        /etc/apt/sources.list.d/passenger.list
    apt-update

    apt-install passenger
}
