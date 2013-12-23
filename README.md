vagrant.sh
==========

Provisioning Helper for Vagrant. These have been tested only on the vanilla precise32 box provided by the Vagrant people.

Modules
-------

- **base**

  The Base module will set LC\_ALL to en\_US.UTF-8 and the after it has been loaded.
  It'll also fix NFS issues for you (it creates a vagrant-nfs user) and delete existing bash history.

  To load a module

        provision modulename ...

  You can also set the timezone with

        set-timezone timezone

  To run a command as another user

        as vagrant "command ..."

  To check if the system supports a command

        can command || apt-install something

  To set the directory which you'll enter after `vagrant ssh`

        redir [directory(=/vagrant)]

- **build**

  This module installs Debians build-essential and sets up ccache.

- **apt**

  This module updates the package cache every two days or when the /etc/apt/sources.list has been changed.
  By default it also overwrites the sources to use mirrors, set `NO_MIRRORS=1` to prevent this from happending.

  After the module has been loaded you can check if a package is installed

        has packagename

  You can also install package(s) unattended

        apt-install packagename ...

- **pgsql**

  This modules sets up PostgreSQL and creates a vagrant user and database.

- **mysql**

  This modules sets up MySQL and creates a vagrant user and database.

- **mongo**

  This modules sets up MongoDB.

- **apache**

  This module provides provides helper to install and configure apache.

  To install Apache

        setup-apache [mpm(=worker)] [DocumentRoot(=/vagrant/public)]

  To change the DocumentRoot

        set-docroot [directory]

- **wordpress**

  This module sets up (deploys to in /vagrant/wordpress if no wp-config.php can be found) WordPress.

- **ruby**

  This module provides helper for installing rubies provided by Ubuntu.

        set-ruby [version]

  Note: *For MRI versions below 1.9 the ruby1.8 packages will be installed. Right now this is 1.8.7. For MRIs after 1.9 the package installed is 1.9.1 which maps to Ruby 1.9.3*

- **ruby-essential**

  This module provides helper for installing bundles and executing rake tasks.

  Check if a gem is present in /vagrant/Gemfile.lock.

        bundles gemname [Gemfile]

  Install bundled gems (w/o doc and production) defined in /vagrant/Gemfile into ~/gems.

        install-bundle [path/to/Gemfile/directory/]

  Run rake tasts as vagrant user.

        carry-out [tasks]

- **passenger**

  This module installs the packaged passenger standalone and provides helper to start Rack applications.

  Start a daemonized passenger on given port in given directory (defaults to port 3000 and and /vagrant).

        on [port(=3000)] [directory(=/vagrant)]

- **request**

  This module includes functions to download resources from a webserver. It will automatically download only resources that have changed after being downloaded during the last provisioning.

  To perform an action after a resource has been download use

        not-modified http://host/database.tar.bz2 || {
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

    source /vagrant/.sh/base.sh
    set-timezone 'Europe/Berlin'
    provision modulename ...

TODOs
-----

- keep the documentation up to date...
- apt-install only if has fails
