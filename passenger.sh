#!/usr/bin/env bash

provision ruby

function on () {
    local port=${1:-3000}
    local directory=`readlink -f ${2:-/vagrant}`
    local pidfile="${directory}/tmp/pids/passenger.${port}.pid"

    can passenger || install-passenger

    mkdir -p $directory/tmp/pids $directory/log 2>/dev/null

    passenger status --pid-file ${pidfile} | grep -q 'is running' && {
        touch $directory/tmp/restart.txt && return 0
    } || {
        local logfile="${directory}/log/passenger.${port}.log"
        local start="passenger start ${directory} --daemonize
            --pid-file ${pidfile} --log-file ${logfile}
            --port $port --user $user"

        # TODO create service
        # http://stackoverflow.com/questions/5489889/how-can-i-keep-a-passenger-standalone-up-even-after-a-restart
        if [ -e $directory/Gemfile ];
        then
            install-bundle $directory
            BUNDLE_GEMFILE=$directory/Gemfile bundle exec $start && return 0
        else
            $start && return 0
        fi
    }

    return 1
}
