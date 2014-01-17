#!/usr/bin/env bash

provision ruby build rack database

function rails-on () {
    local directory=`readlink -f ${2:-/vagrant}`
    local name=`basename $directory`
    local working_directory=`pwd`

    [ -d $directory ] || mkdir -p $directory
    cd $directory

    [ -e $directory/config.ru ] || {
        echo "Deploying Rails app into ${directory}..."

        set-ruby 2.1
        can rails || gem install rails --no-ri --no-rdoc >/dev/null

        as $user "yes | rails new . --database=$DB_DRIVER --skip-bundle" >/dev/null

        sed -i "s/^# gem 'therubyracer'/gem 'therubyracer'/g" "$directory/Gemfile"
        # TODO
        # config/environments/development.rb: config.assets.debug = false
    }

    # create databases
    create-db-user $name
    create-db "${name}_development" $name
    create-db "${name}_production" $name
    create-db "${name}_test" $name

    carry-out log:clear tmp:clear db:migrate

    rackup-on $1 $2
    cd $working_directory
}
