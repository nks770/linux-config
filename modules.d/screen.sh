#!/bin/bash

# Functions for detecting and building the Vim text editor

function screenInstalled() {
# Cannot evaulate if we dont have modules installed
if [ ! -f /etc/profile.d/modules.sh ] ; then
  return 1
fi
# Load modules if not loaded already
if [ -z "${MODULEPATH}" ] ; then
  source /etc/profile.d/modules.sh
fi 
# If modules is OK, then check screen
if [ ! -f ${MODULEPATH}/screen/${1} ] ; then
  return 1
else
  return 0
fi
}

function check_screen() {
if screenInstalled ${1}; then
  echo "screen ${1} is installed."
else
  build_screen ${1}
fi
}

function build_screen() {

# Get desired version number to install
screen_v=${1}
if [ -z "${screen_v}" ] ; then
  screen_v=4.8.0
fi

#case ${screen_v} in
#8.2)
#   screen_srcdir=screen82
#   ;;
#*)
#   screen_srcdir=screen-${screen_v}
#   ;;
#esac

screen_srcdir=screen-${screen_v}

echo "Installing screen ${screen_v}..."

check_modules
#check_tcl ${tcl_tk_ver}
#check_tk ${tcl_tk_ver}

downloadPackage screen-${screen_v}.tar.gz

cd ${tmp}

if [ -d ${tmp}/${screen_srcdir} ] ; then
  rm -rf ${tmp}/${screen_srcdir}
fi

tar xvfz ${pkg}/screen-${screen_v}.tar.gz
cd ${tmp}/${screen_srcdir}
./configure --prefix=${opt}/screen-${screen_v} \
            --with-socket-dir=/run/screen \
            --with-sys-screenrc=${opt}/screen-${screen_v}/etc/screenrc

make -j ${ncpu} && make install

if [ ! $? -eq 0 ] ; then
  exit 4
fi

# Create the environment module
if [ -z "${MODULEPATH}" ] ; then
  source /etc/profile.d/modules.sh
fi 
mkdir -pv ${MODULEPATH}/screen
cat << eof > ${MODULEPATH}/screen/${screen_v}
#%Module

proc ModulesHelp { } {
   puts stderr "Puts screen-${screen_v} into your environment"
}

set VER ${screen_v}
set PKG ${opt}/screen-\$VER

module-whatis   "Loads screen-${screen_v}"
conflict screen

prepend-path PATH \$PKG/bin
prepend-path MANPATH \$PKG/share/man

eof

cd ${root}
rm -rf ${tmp}/${screen_srcdir}

}
