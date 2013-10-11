#!/usr/bin/env bash

provision ruby

# checks if a gem is bundled
function bundles () {
    local lockfile=`readlink -f "${2:-/vagrant/Gemfile}.lock"`
    grep -o " ${1}[ $]" $lockfile >/dev/null 2>&1
}
# installs bundle from given path or /vagrant
function install-bundle () {
    local gemfile=`readlink -f "${1:-/vagrant}/Gemfile"`

    while :
    do
        can bundle && break || gem install --no-ri --no-rdoc bundler >/dev/null
    done

    bundles pg $gemfile && {
        provision pgsql
        has libpq-dev \
        || apt-install libpq-dev
    }
    bundles curb $gemfile && {
        has libcurl4-openssl-dev \
        || apt-install libcurl4-openssl-dev
    }
    bundles nokogiri $gemfile && {
        has libxslt-dev && has libxml2-dev \
        || apt-install libxslt-dev libxml2-dev
    }
    bundles rmagick $gemfile && {
        has libmagickwand-dev \
        || apt-install libmagickwand-dev
    }
    bundles sqlite3 $gemfile && {
        has libsqlite3-dev \
        || apt-install libsqlite3-dev
    }

    echo "Installing bundle..."
    as vagrant "bundle install --no-deployment --path=~/gems --gemfile=${gemfile} --quiet --no-cache --without doc production"
}
# runs rake tasts as vagrant user
function carry-out () {
    local directory=`pwd`

    while getopts "at:" flag
    do
        case "${flag}" in
            at)
                directory=$OPTARG
                ;;
        esac
    done

    gemfile=`readlink -f "${directory}/Gemfile"`
    rakefile=`readlink -f "${directory}/Rakefile"`

    as vagrant "BUNDLE_GEMFILE=${gemfile} bundle exec rake -f${rakefile} $@"
}
