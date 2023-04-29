#!/bin/bash

# Functions for detecting and building yasm
echo 'Loading yasm...'

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

config="./configure --prefix=${opt}/yasm-${yasm_v}"

if [ ${debug} -gt 0 ] ; then
  ./configure --help
  echo ''
  echo ${config}
  read k
fi

${config}

if [ ${debug} -gt 0 ] ; then
  echo '>> Configure complete'
  read k
fi

make -j ${ncpu}
if [ ! $? -eq 0 ] ; then
  exit 4
fi
if [ ${debug} -gt 0 ] ; then
  echo '>> Build complete'
  read k
fi

if [ ${run_tests} -gt 0 ] ; then
  make check
  echo '>> Tests complete'
  read k
fi

make install
if [ ! $? -eq 0 ] ; then
  exit 4
fi
if [ ${debug} -gt 0 ] ; then
  echo '>> Install complete'
  read k
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
