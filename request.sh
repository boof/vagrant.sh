#!/usr/bin/env bash

# returns the last modification date in a human readable format
function mtime () {
    stat --format '%y' $1
}
# converts a date into the HTTP date format
function httpdate () {
    local human_readable_date=`echo "$*"`
    date --date="${human_readable_date}" +'%a, %e %b %Y %T GMT'
}
# downloads a resource if the resource is newer than the local file or the
# local file does not exist
function not-modified () {
    local bn=`basename $1`
    if [ -r "$bn" ]; then
        local date=`httpdate $(mtime $bn)`
        wget --quiet --no-http-keep-alive --output-document=$bn --header="If-Modified-Since: $date" $1
    else
        wget --quiet --no-http-keep-alive --output-document=$bn $1
    fi

    [ $? -eq 0 ] && return 1
    return 0
}
