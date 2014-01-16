#!/usr/bin/env bash

provision apt

## Public
function rackup-on () {
    local port=${1:-3000}
    local directory=`readlink -f ${2:-/vagrant}`
    local config=$directory/unicorn.conf.rb

    # configure unicorn
    [ -e $config ] || {
        cp "$DIR/contrib/unicorn.conf.rb" "$directory/unicorn.conf.rb"

        sed -i "s/listen 3000/listen $port/" "$directory/unicorn.conf.rb"
        sed -i 's|"/vagrant|"'$directory'|g' "$directory/unicorn.conf.rb"
        sed -i "s|unicorn/vagrant|unicorn/`basename $directory`|g" "$directory/unicorn.conf.rb"
    }

    # create directory
    [ -d /var/run/unicorn ] || mkdir /var/run/unicorn
    chown -R $user:$group /var/run/unicorn

    # (re)start unicorn
    local pidfile=`grep -P '^pid ' $config | cut -d ' ' -f 2 | sed "s/^\([\"']\)\(.*\)\1\$/\2/g"`
    [ -e $pidfile ] && kill -s HUP `cat $pidfile` 2>/dev/null || {
        local start="unicorn --daemonize --config-file $config"

        # install unicorn unless installed?
        can unicorn || gem install unicorn --no-ri --no-rdoc >/dev/null

        # TODO create service
        if [ -e $directory/Gemfile ];
        then
            install-bundle $directory
            BUNDLE_GEMFILE=$directory/Gemfile as $user "bundle exec $start" && return 0
        else
            as $user $start && return 0
        fi
    }
}

# installs Ruby (defined in /vagrant/.ruby-version or given as parameter)
# and modifies PATH
function set-ruby () {
    local version=`cat /vagrant/.ruby-version 2>/dev/null`
    version=`mangle-ruby-version ${1:-$version}`

    # install unless installed?
    can ruby$version || apt-install ruby$version ruby$version-dev rubygems$version

    # switch current ruby unless current? version
    local current=`mangle-ruby-version $(ruby -v | grep -oP '\d+\.\d+\.\d+')`
    [ "v$version" = "v$current" ] || ruby-switch --set ruby$version

    # then ensure bundler works
    while :
    do
        can bundle && break || gem install --no-ri --no-rdoc bundler >/dev/null
    done
}

# installs bundle from given path or /vagrant
function install-bundle () {
    local gemfile=`readlink -f "${1:-/vagrant}/Gemfile"`

    install-gem-dependencies $gemfile

    as vagrant 'bundle check' >/dev/null || {
        echo "Installing bundle from ${gemfile}..."
        as vagrant "bundle install --no-deployment --path=/home/vagrant/gems --gemfile=${gemfile} --no-cache --without doc production" >/dev/null
    }
}
# runs rake tasts as vagrant user
function carry-out () {
    local directory=`pwd`

    while getopts "d:" flag
    do
        case "${flag}" in
            d)
                directory=$OPTARG
                ;;
        esac
    done

    gemfile=`readlink -f "${directory}/Gemfile"`
    rakefile=`readlink -f "${directory}/Rakefile"`

    install-bundle "${directory}"
    as vagrant "BUNDLE_GEMFILE=${gemfile} bundle exec rake -f${rakefile} $@"
}

## Helper
function mangle-ruby-version () {
    local version=$1

    expr match $version 1.9 >/dev/null && {
        if [ "v${version}" \< "v1.9.3" ]; then
            version=1.9.1
        else
            version=1.9.3
        fi
    } || version=`expr substr $version 1 3`

    echo $version
}
# checks if a gem is bundled
function bundles () {
    local lockfile=`readlink -f "${2:-/vagrant/Gemfile}.lock"`
    grep -o " ${1}[ $]" $lockfile >/dev/null 2>&1
}
# install required packages
function install-gem-dependencies () {
    local gemfile=${1}

    bundles pg $gemfile && provision build pgsql

    bundles curb $gemfile && {
        provision build
        has libcurl4-openssl-dev ||
        apt-install libcurl4-openssl-dev
    }
    bundles nokogiri $gemfile && {
        provision build
        has libxslt1-dev && has libxml2-dev ||
        apt-install libxslt1-dev libxml2-dev
    }
    bundles rmagick $gemfile && {
        provision build
        has libmagickwand-dev ||
        apt-install libmagickwand-dev
    }
    bundles sqlite3 $gemfile && {
        provision build
        has libsqlite3-dev ||
        apt-install libsqlite3-dev
    }
    bundles resque $gemfile && {
        has redis-server ||
        apt-install redis-server
    }

    bundles rails $gemfile && provision rails

}

## Deprecated
function on () {
    echo "on is deprecated, use rackup-on instead." >&2
    rackup-on $@
}

## Bootstrap
can apt-add-repository || apt-install python-software-properties

[ -f /etc/apt/sources.list.d/brightbox-ruby-ng-precise.list ] || {
    apt-add-repository ppa:brightbox/ruby-ng >/dev/null
    apt-update
}

can ruby-switch || apt-install ruby rubygems ruby-switch
