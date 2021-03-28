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
if [ ! -f "/usr/include/X11/Xlib.h" ] ; then
  # X11/Xlib.h header file needed to build Tk
  packages="${packages} libX11-devel"
fi

if [ ! -z "${packages}" ] ; then
  dnf -y install ${packages}
fi

}
