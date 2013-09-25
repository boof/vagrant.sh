#!/usr/bin/env bash

provision apt

has build-essential || apt-install build-essential

# installs compiler cache
has ccache || {
    echo "Installing ccache..."
    apt-install ccache

    ln -s /usr/bin/ccache /usr/local/bin/gcc
    ln -s /usr/bin/ccache /usr/local/bin/g++
    ln -s /usr/bin/ccache /usr/local/bin/cc
}
