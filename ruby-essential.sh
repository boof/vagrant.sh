#!/usr/bin/env bash

provision ruby

# checks if a gem is bundled
function bundles () {
    local gemfile="${2:-/vagrant/Gemfile}"
    grep -o "gem ['\"]${1}['\"]" $gemfile >/dev/null 2>&1
}
# installs bundle from given path or /vagrant
function install-bundle () {
    local gemfile="${1:-/vagrant}/Gemfile"

    while :
    do
        gem install --no-ri --no-rdoc bundler >/dev/null && break
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

    echo "Installing bundle..."
    su -c "bundle install --no-deployment --path=~/gems --gemfile=${gemfile} --quiet --no-cache --without doc test production" - vagrant
}
# runs rake tasts as vagrant user
function carry-out () {
    su -c "bundle exec rake $@ >/dev/null" - vagrant
}
