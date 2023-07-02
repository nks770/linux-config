#!/bin/bash

# Functions for detecting and building rarlinux
echo 'Loading rarlinux...'

function rarlinuxInstalled() {
# Cannot evaulate if we dont have modules installed
if [ ! -f /etc/profile.d/modules.sh ] ; then
  return 1
fi
# Load modules if not loaded already
if [ -z "${MODULEPATH}" ] ; then
  source /etc/profile.d/modules.sh
fi 
# If modules is OK, then check yasm
if [ ! -f ${MODULEPATH}/rarlinux/${1} ] ; then
  return 1
else
  return 0
fi
}

function check_rarlinux() {
if rarlinuxInstalled ${1} ; then
  echo "rarlinux-${1} is installed."
else
  build_rarlinux ${1}
fi
}

function build_rarlinux() {

# Get desired version number to install
rarlinux_v=${1}
if [ -z "${rarlinux_v}" ] ; then
  rarlinux_v=6.20
fi
rarlinux_vv=${rarlinux_v%.*}${rarlinux_v#*.}
rarlinux_srcdir=rarlinux-${rarlinux_v}

echo "Installing rarlinux version ${rarlinux_v}..."

check_modules

downloadPackage rarlinux-x64-${rarlinux_vv}.tar.gz

mkdir -pv ${opt}/${rarlinux_srcdir}

cd ${opt}/${rarlinux_srcdir}
tar xvfz ${pkg}/rarlinux-x64-${rarlinux_vv}.tar.gz

if [ ! $? -eq 0 ] ; then
  exit 4
fi

mv -fv rar bin

# Create the environment module
if [ -z "${MODULEPATH}" ] ; then
  source /etc/profile.d/modules.sh
fi
mkdir -pv ${MODULEPATH}/rarlinux
cat << eof > ${MODULEPATH}/rarlinux/${rarlinux_v}
#%Module

proc ModulesHelp { } {
   puts stderr "Puts rarlinux-${rarlinux_v} into your environment"
}

set VER ${rarlinux_v}
set PKG ${opt}/rarlinux-\$VER

module-whatis   "Loads rarlinux-${rarlinux_v}"
conflict rarlinux

prepend-path PATH \$PKG/bin

eof

if [ ${debug} -gt 0 ] ; then
  echo '>> Install complete'
  read k
fi

cd ${root}

}
