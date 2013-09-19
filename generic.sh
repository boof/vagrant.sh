#!/usr/bin/env bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
LOADED="generic apt"

function includes () {
  local e
  for e in "${@:2}"; do [[ "$e" == "$1" ]] && return 0; done
  return 1
}

function provision () {

    source "${DIR}/apt.sh"

    local module

    for module in $@; do
        # prevent dependency loops
        includes "${module}" $LOADED && continue

        # handle dependencies
        case "${module}" in
            wordpress)
                provision apache mysql
                ;;
            ruby)
                provision build
                ;;
            rack)
                provision ruby
                ;;
        esac

        LOADED+=" ${module}"
        source "${DIR}/${module}.sh"
    done

}
function set-timezone () {
    grep $1 /etc/timezone >/dev/null || {
        echo $1 > /etc/timezone
        dpkg-reconfigure --frontend noninteractive tzdata 2>/dev/null
    }
}

export LC_ALL=en_US.UTF-8
