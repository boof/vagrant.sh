#!/usr/bin/env bash

provision apt

# installs Ruby (defined in /vagrant/.ruby-version or given as parameter)
# and modifies PATH
function set-ruby () {
    version=`cat /vagrant/.ruby-version 2>/dev/null`
    version=${1:-$version}

    apt_install ruby$version
    update-alternatives --set ruby /usr/bin/ruby$version >/dev/null
}

# checks if a gem is bundled
function bundles () {
    local gemfile="${1:/vagrant/Gemfile}"
    grep -o "gem ['\"]$1['\"]" $gemfile >/dev/null 2>&1
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
        apt_install libpq-dev
    }

    echo "Installing bundle..."
    su -c "bundle install --no-deployment --path=~/gems --gemfile=${gemfile} --quiet --no-cache --without doc test production" - vagrant
}
# runs rake tasts as vagrant user
function carry-out () {
    su -c "bundle exec rake $@ >/dev/null" - vagrant
}
