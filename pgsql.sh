#!/usr/bin/env bash

provides database
provision apt

DB_DRIVER=postgresql

function create-db-user () {
	local user=${1}
	sudo -u postgres createuser --superuser $user
}

function create-db () {
	local db=${1}
	local user=${2:-vagrant}
	sudo -u postgres createdb --owner=$user $db
}

# setup postgresql to work well with vagrant
has postgresql-9.1 || {
	echo "Setting up PostgreSQL server..."
	apt-install postgresql-9.1 postgresql-contrib-9.1
	includes "build" $LOADED && apt-install postgresql-server-dev-9.1

	create-db-user vagrant
	create-db vagrant

	local search='local   all             all                                     peer'
	local replace='local   all             all                                     trust'
	local search_and_replace="s/${search}/${replace}/"

	sed -i "${search_and_replace}" /etc/postgresql/9.1/main/pg_hba.conf
	service postgresql reload >/dev/null
}
