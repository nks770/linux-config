#!/bin/bash

# Functions for detecting and building the Vim text editor

function yasmInstalled() {
# Cannot evaulate if we dont have modules installed
if [ ! -f /etc/profile.d/modules.sh ] ; then
  return 1
fi
# Load modules if not loaded already
if [ -z "${MODULEPATH}" ] ; then
  source /etc/profile.d/modules.sh
fi 
# If modules is OK, then check yasm
if [ ! -f ${MODULEPATH}/yasm/${1} ] ; then
  return 1
else
  return 0
fi
}

function check_yasm() {
if yasmInstalled ${1}; then
  echo "yasm ${1} is installed."
else
  build_yasm ${1}
fi
}

function build_yasm() {

# Get desired version number to install
yasm_v=${1}
if [ -z "${yasm_v}" ] ; then
  yasm_v=1.3.0
fi
yasm_srcdir=yasm-${yasm_v}

echo "Installing yasm ${yasm_v}..."

check_modules

downloadPackage yasm-${yasm_v}.tar.gz

cd ${tmp}

if [ -d ${tmp}/${yasm_srcdir} ] ; then
  rm -rf ${tmp}/${yasm_srcdir}
fi

tar xvfz ${pkg}/yasm-${yasm_v}.tar.gz
cd ${tmp}/${yasm_srcdir}

./configure --prefix=${opt}/yasm-${yasm_v}
make -j ${ncpu} && make install
if [ ! $? -eq 0 ] ; then
  exit 4
fi

# Create the environment module
if [ -z "${MODULEPATH}" ] ; then
  source /etc/profile.d/modules.sh
fi
mkdir -pv ${MODULEPATH}/yasm
cat << eof > ${MODULEPATH}/yasm/${yasm_v}
#%Module

proc ModulesHelp { } {
   puts stderr "Puts yasm-${yasm_v} into your environment"
}

set VER ${yasm_v}
set PKG ${opt}/yasm-\$VER

module-whatis   "Loads yasm-${yasm_v}"
conflict yasm

prepend-path CPATH \$PKG/include
prepend-path C_INCLUDE_PATH \$PKG/include
prepend-path CPLUS_INCLUDE_PATH \$PKG/include
prepend-path LD_LIBRARY_PATH \$PKG/lib
prepend-path PATH \$PKG/bin
prepend-path MANPATH \$PKG/share/man

eof

cd ${root}
rm -rf ${tmp}/${yasm_srcdir}

}
