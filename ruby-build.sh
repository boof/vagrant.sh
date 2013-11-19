#!/usr/bin/env bash
# This module provides build facilities for ruby, rubygems and passenger.
# Author: Florian Aßmann <florian.assmann@email.de>

provides ruby
provision build

# build given Ruby version
function __ruby () {
    echo "Building Ruby $1..."
    MAKE_OPTS=-j2 RUBY_BUILD_CACHE_PATH=$HOME/.ruby-build ruby-build $1 /usr/local/ruby-$1 >/dev/null 2>&1
}

# installs Ruby (defined in /vagrant/.ruby-version or given as parameter)
# and modifies PATH
function set-ruby () {
    version=`cat /vagrant/.ruby-version 2>/dev/null`
    version=${1:-$version}

    [ -x /usr/local/ruby-$version/bin/ruby ] && return

    __ruby $version || {
        echo "Could not install Ruby ${version}!" 1>&2
        exit 1
    }

    echo "export PATH=/usr/local/ruby-$version/bin:\$PATH" \
        | install --backup=none /dev/stdin /etc/profile.d/ruby.sh

    . /etc/profile.d/ruby.sh

    update-alternatives --install /usr/bin/ruby ruby /usr/local/ruby-$version/bin/ruby 500 \
        --slave /usr/share/man/man1/ruby.1 ruby.1 /usr/local/ruby-$version/share/man/man1/ruby.1 \
        --slave /usr/bin/ri ri /usr/local/ruby-$version/bin/ri \
        --slave /usr/bin/irb irb /usr/local/ruby-$version/bin/irb

    update-alternatives --set ruby /usr/local/ruby-$version/bin/ruby >/dev/null

    # TODO do this for rubygems, too
}

function install-passenger () {
    # TODO add support for passenger gem
}

# installs or updates the ruby builder
can ruby-build && {
    # TODO update ruby-build
    cd /usr/local/src/ruby-build
    git remote update >/dev/null
    # git status -suno || {
    #     git pull --rebase
    #     ./install.sh >/dev/null
    # }
} || {
    echo "Installing Ruby builder..."
    apt-install git

    cd /usr/local/src
    git clone https://github.com/sstephenson/ruby-build.git >/dev/null
    cd ruby-build
    ./install.sh >/dev/null
}

provision ruby-essential
