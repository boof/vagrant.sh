#!/usr/bin/env bash

provision ruby
provides middleman

function middleman-on {
	local directory=`readlink -f ${2:-/vagrant}`
	local name=`basename $directory`
	local working_directory=`pwd`

	[ -d $directory ] || {
		middleman init $directory
	}

	cd $directory
	middleman server -p $1 --force-polling
}

can middleman || {
	echo "Setting up node …"
	[[ $(nodejs -v) == v0.10.* ]] || {
		add-apt-repository -y ppa:chris-lea/node.js
		apt-get update
  	apt-install nodejs
  }

	echo "Setting up middleman …"
	set-ruby 2.1
	gem install --no-ri --no-rdoc middleman
}