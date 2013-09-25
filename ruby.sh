#!/usr/bin/env bash

provision apt

# installs Ruby (defined in /vagrant/.ruby-version or given as parameter)
# and modifies PATH
function set-ruby () {
    version=`cat /vagrant/.ruby-version 2>/dev/null`
    version=${1:-$version}

    apt-install ruby$version
    update-alternatives --set ruby /usr/bin/ruby$version >/dev/null
}

provision ruby-essential
