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
        # FIXME conditional logic not working...
        has libxslt1-dev && has libxml2-dev \
        || apt-install libxslt1-dev libxml2-dev
    }

    echo "Installing bundle..."
    as vagrant "bundle install --no-deployment --path=~/gems --gemfile=${gemfile} --quiet --no-cache --without doc production"
}
# runs rake tasts as vagrant user
function carry-out () {
    local gemfile="${2:-/vagrant}/Gemfile"
    as vagrant "bundle exec --gemfile=${gemfile} rake $1 >/dev/null"
}
