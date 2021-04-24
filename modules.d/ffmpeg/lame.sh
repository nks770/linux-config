#!/bin/bash

# Functions for detecting and building the Vim text editor

function lameInstalled() {
# Cannot evaulate if we dont have modules installed
if [ ! -f /etc/profile.d/modules.sh ] ; then
  return 1
fi
# Load modules if not loaded already
if [ -z "${MODULEPATH}" ] ; then
  source /etc/profile.d/modules.sh
fi 
# If modules is OK, then check lame
if [ ! -f ${MODULEPATH}/lame/${1} ] ; then
  return 1
else
  return 0
fi
}

function check_lame() {
if lameInstalled ${1}; then
  echo "lame ${1} is installed."
else
  build_lame ${1}
fi
}

function build_lame() {

# Get desired version number to install
lame_v=${1}
if [ -z "${lame_v}" ] ; then
  lame_v=3.100
fi
lame_srcdir=lame-${lame_v}

echo "Installing lame ${lame_v}..."

check_modules
module purge
module list

downloadPackage lame-${lame_v}.tar.gz

cd ${tmp}

if [ -d ${tmp}/${lame_srcdir} ] ; then
  rm -rf ${tmp}/${lame_srcdir}
fi

cd ${tmp}
tar xvfz ${pkg}/lame-${lame_v}.tar.gz
cd ${tmp}/${lame_srcdir}

./configure --prefix=${opt}/lame-${lame_v}
make -j ${ncpu} && make install

if [ ! $? -eq 0 ] ; then
  exit 4
fi

# Create the environment module
if [ -z "${MODULEPATH}" ] ; then
  source /etc/profile.d/modules.sh
fi 
mkdir -pv ${MODULEPATH}/lame
cat << eof > ${MODULEPATH}/lame/${lame_v}
#%Module

proc ModulesHelp { } {
   puts stderr "Puts lame-${lame_v} into your environment"
}

set VER ${lame_v}
set PKG ${opt}/lame-\$VER

module-whatis   "Loads lame-${lame_v}"
conflict lame

prepend-path CPATH \$PKG/include
prepend-path C_INCLUDE_PATH \$PKG/include
prepend-path CPLUS_INCLUDE_PATH \$PKG/include
prepend-path LD_LIBRARY_PATH \$PKG/lib
prepend-path PATH \$PKG/bin
prepend-path MANPATH \$PKG/share/man

eof

cd ${root}
rm -rf ${tmp}/${lame_srcdir}

}
