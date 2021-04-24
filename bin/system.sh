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
if [ ! -f "$(which g++ 2>&1)" ] ; then
  packages="${packages} gcc-c++"
fi
if [ ! -f "$(which patch 2>&1)" ] ; then
  packages="${packages} patch"
fi
if [ ! -f "$(which bzip2 2>&1)" ] ; then
  packages="${packages} bzip2"
fi
if [ ! -f "$(which flex 2>&1)" ] ; then
  packages="${packages} flex"
fi
if [ ! -f "$(which bison 2>&1)" ] ; then
  packages="${packages} bison"
fi
if [ ! -f "$(which perl 2>&1)" ] ; then
  packages="${packages} perl"
fi
if [ ! -f "/usr/include/X11/Xlib.h" ] ; then
  # X11/Xlib.h header file needed to build Tk
  packages="${packages} libX11-devel"
fi
if [ ! -f "/usr/include/cursesw.h" ] ; then
  # ncursesw header file needed to build Vim 
  packages="${packages} ncurses-devel"
fi
if [ ! -f "/usr/include/ffi.h" ] ; then
  # libffi header file (optionally) needed to build Python
  packages="${packages} libffi-devel"
fi
if [ ! -f "/usr/include/lzma.h" ] ; then
  # liblzma header file (optionally) needed to build Python
  packages="${packages} xz-devel"
fi
if [ ! -f "/usr/include/zlib.h" ] ; then
  # zlib header file needed to build Python
  packages="${packages} zlib-devel"
fi
if [ ! -f "/usr/include/bzlib.h" ] ; then
  # bzip2 header file (optionally) needed to build Python
  packages="${packages} bzip2-devel"
fi
if [ ! -f "/usr/include/openssl/ssl.h" ] ; then
  # openssl header file (optionally) needed to build Python
  packages="${packages} openssl-devel"
fi
if [ ! -f "/usr/include/freetype2/freetype/freetype.h" ] ; then
  # freetype2 is needed to build libass (for ffmpeg)
  packages="${packages} freetype-devel"
fi
if [ ! -f "/usr/include/fribidi/fribidi.h" ] ; then
  # fribidi is needed to build libass (for ffmpeg)
  packages="${packages} fribidi-devel"
fi
if [ ! -f "/usr/include/fontconfig/fontconfig.h" ] ; then
  # fontconfig is needed to build libass (for ffmpeg)
  packages="${packages} fontconfig-devel"
fi

if [ ! -z "${packages}" ] ; then
  dnf -y install ${packages}
fi

}
