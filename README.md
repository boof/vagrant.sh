vagrant.sh
==========

Provisioning Helper for Vagrant. These have been tested only on the vanilla precise32 box provided by the Vagrant people.

Modules
-------

- base

  The Base module will set LC_ALL to en_US.UTF-8 and the when it's loaded

        provision modulename ...

  You can also set the timezone with:

        set-timezone 'Europe/Berlin'

- build

  This module installs Debians build-essential and sets up ccache.

- apt

  This module updates the package cache every two days or when the /etc/apt/sources.list hase been changed.

  By default it also overwrites the sources to use mirrors.

  After the module has been loaded you can check if a package is installed:

        has packagename

  You can also install package(s) unattended:

        apt_install packagename1 ...

- pgsql

  This modules sets up PostgreSQL and creates a vagrant user and database.

- mysql

  This modules sets up MySQL and creates a vagrant user and database.

- wordpress

  This module sets up WordPress.

- ruby

  This module will help you installing Rubies. It will installs the ruby-build standalone and setup ccache to speed up compilation time when it's loaded.

  To build a not already built Ruby you have to add one of the following lines into your provisioning script after you included the ruby module.

        set-ruby 2.0.0-p247 # or
        set-ruby # will use /vagrant/.ruby-version

  It works best across multiple boxes if you sync the cache folder via NFS.

        config.vm.synced_folder '~/.ccache', "/home/vagrant/.ccache", nfs: true, create: true

  It is also a good practice to share a RUBY_BUILD_CACHE_PATH across machines.

        config.vm.synced_folder ~/.ruby-build, "/home/vagrant/.ruby-build", nfs: true, create: true

  Functions included are:

    - __ruby version

      Builds a ruby version unconditionally and installs it into /usr/local.

    - set-ruby [version]

      Builds a non-existing ruby version and modifies the PATH globally.

    - bundles gemname [Gemfile]

      Checks if a gem is present in /vagrant/Gemfile.lock.

    - install-bundle [path/to/Gemfile]

      Installs bundles gems (w/o doc and production) defined in /vagrant/Gemfile into ~/gems

- rack

  This module contains helper to provision Rack based applications.

- request

  This module includes functions to download resources from a webserver. It will automatically download only resources that have changed after being downloaded during the last provisioning. To perform an action after a resource has been download:

        request http://host/database.tar.bz2 || {
            tar -xjf database.tar.bz2 | mysql vagrant
        }

Usage
-----

To use a shell script for provisioning you have to tell Vagrant about it in your Vagrantfile:

    config.vm.provision "shell", path: "provision.sh"

You're advised to submodule this repository into your own:

    $ git submodule add https://github.com/boof/vagrant.sh.git .sh

To load the modules just source the generic module into your provisioning script (provision.sh) and use the provision function:

    #!/usr/bin/env bash

    source /vagrant/.sh/generic.sh
    set-timezone 'Europe/Berlin'
    provision modulename ...

TODOs
-----

- test if request works as expected
- generalize the Request.request() function
- complete the documentation
