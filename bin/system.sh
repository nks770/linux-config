#!/bin/bash

function installSystemPackages() {

packages=""

if [ ! -f "$(which wget 2>&1)" ] ; then
  packages="${packages} wget"
fi
if [ ! -f "$(which make 2>&1)" ] ; then
  packages="${packages} make"
fi
if [ ! -f "$(which gcc 2>&1)" ] ; then
  packages="${packages} gcc"
fi

if [ ! -z "${packages}" ] ; then
  dnf -y install ${packages}
fi

}
