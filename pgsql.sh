#!/usr/bin/env bash

provision apt

# setup postgresql to work well with vagrant
has postgresql-9.1 || {
    echo "Setting up PostgreSQL server..."
    apt_install postgresql-9.1

    sudo -u postgres createuser --superuser vagrant
    sudo -u postgres createdb --owner=vagrant vagrant
}
