#!/usr/bin/env bash

provision apt

function install-passenger () {
    echo 'Setting up Passenger Standalone...'
    gpg --keyserver keyserver.ubuntu.com --recv-keys 561F9B9CAC40B2F7 >/dev/null
    gpg --armor --export 561F9B9CAC40B2F7 | sudo apt-key add - >/dev/null

    apt-install apt-transport-https

    echo 'deb https://oss-binaries.phusionpassenger.com/apt/passenger precise main' > /etc/apt/sources.list.d/passenger.list
    aptitude update >/dev/null || exit 1

    apt-install passenger
}

# installs Ruby (defined in /vagrant/.ruby-version or given as parameter)
# and modifies PATH
function set-ruby () {
	local version=`cat /vagrant/.ruby-version 2>/dev/null`
	version=${1:-$version}

	if [ "v${version}" \< "v1.9" ]; then
		version=1.8
	else
		version=1.9.1
	fi

	has ruby$version ||	{
		apt-install \
			ruby$version \
			ruby$version-dev \
			libreadline-ruby$version \
			rubygems$version \
			libruby$version \
			libopenssl-ruby

		update-alternatives --set ruby /usr/bin/ruby$version >/dev/null
		update-alternatives --set gem /usr/bin/gem$version >/dev/null
	}
}

provision ruby-essential
