#!/usr/bin/env bash

# build given Ruby version
function build_ruby () {
    echo "Building Ruby $1..."
    MAKE_OPTS=-j2 RUBY_BUILD_CACHE_PATH=$HOME/.ruby-build ruby-build $1 /usr/local/ruby-$1 >/dev/null 2>&1
}

# installs Ruby (defined in /vagrant/.ruby-version or given as parameter)
# and modifies PATH
function setup_ruby () {
    version=`cat /vagrant/.ruby-version 2>/dev/null`
    version=${1:-$version}
    [ -x /usr/local/ruby-$version/bin/ruby ] && return

    build_ruby $version || {
        echo "Could not install Ruby ${version}!" 1>&2
        exit 1
    }

    echo "export PATH=/usr/local/ruby-$version/bin:\$PATH" \
        | install --backup=none /dev/stdin /etc/profile.d/ruby.sh

    . /etc/profile.d/ruby.sh
}

# checks if a gem is bundled
function bundles () {
    grep -o "gem ['\"]$1['\"]" /vagrant/Gemfile >/dev/null 2>&1
}
# installs bundle from given path or /vagrant
function install_bundles () {
    while :
    do
        gem install --no-ri --no-rdoc bundler >/dev/null && break
    done

    bundles pg && {
        provision pgsql
        apt_install libpq-dev
    }

    echo "Installing bundle..."
    su -c 'bundle install --no-deployment --path=~/gems --gemfile=/vagrant/Gemfile --quiet --no-cache --without doc test production' - vagrant
}

# installs the ruby builder
can ruby-build && {
    # TODO update ruby-build
    cd /usr/local/src/ruby-build
    git remote update
    # git status -suno || {
    #     git pull --rebase
    #     ./install.sh >/dev/null
    # }
} || {
    echo "Installing Ruby builder..."
    apt_install git

    cd /usr/local/src
    git clone https://github.com/sstephenson/ruby-build.git >/dev/null
    cd ruby-build
    ./install.sh >/dev/null
}
