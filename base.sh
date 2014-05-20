#!/usr/bin/env bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
LOADED="generic"

function as () {
    local login=$1
    shift
    local cmd=`echo "$*"`
    su -c "${cmd}" ${login}
}

function includes () {
  local e
  for e in "${@:2}"; do [[ "$e" == "$1" ]] && return 0; done
  return 1
}
function provides () {
    LOADED+=" $@"
}

# loads provisioning modules and its dependencies
function provision () {
    local module
    for module in $@; do
        # prevent dependency loops
        includes "${module}" $LOADED && continue

        LOADED+=" ${module}"
        source "${DIR}/${module}.sh"
    done
}
function set-timezone () {
    grep -q $1 /etc/timezone || {
        echo $1 > /etc/timezone
        dpkg-reconfigure --frontend noninteractive tzdata 2>/dev/null
    }
}

# checks if the shell supports the given command
function can () {
    command -v "$@" >/dev/null 2>&1
}

function redir () {
    as vagrant "echo ${1:-/vagrant} > /home/vagrant/.redir"
}
function setup-redir () {
    local cmd='[ -f /home/vagrant/.redir ] && cd `cat .redir`'
    local profile=/home/vagrant/.profile
    grep -q "$cmd" $profile || echo $cmd >> $profile
}
setup-redir

# fix issues with nfs sharing
line=`ls -n ${BASH_SOURCE[0]}`
gid=`echo $line | cut -d ' ' -f 4`
uid=`echo $line | cut -d ' ' -f 3`

# have a real user for nfs shares
mount -l -t nfs | grep /vagrant >/dev/null && {
    # assign group id to group
    cut -d ':' -f 3 /etc/group | grep $gid >/dev/null || {
        addgroup --system --gid $gid vagrant-nfs >/dev/null
    }
    # assign user id to user
    cut -d ':' -f 3 /etc/passwd | grep $uid >/dev/null || {
        adduser --system --home /vagrant --no-create-home --shell /bin/false --uid $uid --gid $gid --disabled-password --disabled-login vagrant-nfs >/dev/null
    }
}

group=`cut -d ':' -f 1,3 /etc/group | grep $gid | cut -d ':' -f 1`
user=`cut -d ':' -f 1,3 /etc/passwd | grep $uid | cut -d ':' -f 1`

update-locale LC_ALL=en_US.UTF-8
export LC_ALL=en_US.UTF-8

rm --force /home/vagrant/.bash_history
