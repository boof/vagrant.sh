#!/usr/bin/env bash

provides rack
provision ruby build

# TODO create service
function rackup-on () {
    local port=${1:-3000}
    local directory=`readlink -f ${2:-/vagrant}`
    local config="$directory/unicorn.conf.rb"

    # configure unicorn
    [ -e $config ] || {
        cp "$DIR/contrib/unicorn.conf.rb" $config

        sed -i 's|"/vagrant|"'$directory'|g' $config
        sed -i "s|unicorn/vagrant|unicorn/`basename $directory`|g" $config
    }
    sed -i "s/listen 3000/listen $port/" $config

    # (re)start unicorn
    local pidfile=`grep -P '^pid ' $config | cut -d ' ' -f 2 | sed "s/^\([\"']\)\(.*\)\1\$/\2/g"`
    [ -e $pidfile ] && kill -s HUP `cat $pidfile` 2>/dev/null || {
        local start="unicorn --daemonize --config-file $config"
        local gemfile="$directory/Gemfile"

        # install unicorn unless installed?
        can unicorn || gem install unicorn --no-ri --no-rdoc >/dev/null

        if [ -e $gemfile ];
        then
            # enable unicorn
            grep "'unicorn'" $gemfile | grep -qG '^gem' ||
                echo "gem 'unicorn', group: 'development'" >> $gemfile
            install-bundle $directory

            BUNDLE_GEMFILE=$gemfile as $user "bundle exec $start" && return 0
        else
            as $user $start && return 0
        fi
    }
}

# create directory
[ -d /var/run/unicorn ] || mkdir /var/run/unicorn
chown -R $user:$group /var/run/unicorn
