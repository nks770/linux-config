#!/bin/bash

# Functions for detecting and building cmake

function cmakeInstalled() {
# Cannot evaulate if we dont have modules installed
if [ ! -f /etc/profile.d/modules.sh ] ; then
  return 1
fi
# Load modules if not loaded already
if [ -z "${MODULEPATH}" ] ; then
  source /etc/profile.d/modules.sh
fi 
# If modules is OK, then check cmake
if [ ! -f ${MODULEPATH}/cmake/${1} ] ; then
  return 1
else
  return 0
fi
}

function check_cmake() {
if cmakeInstalled ${1}; then
  echo "cmake ${1} is installed."
else
  build_cmake ${1}
fi
}

function build_cmake() {

# Get desired version number to install
cmake_v=${1}
if [ -z "${cmake_v}" ] ; then
  cmake_v=3.11.4
fi
cmake_srcdir=cmake-${cmake_v}

echo "Installing cmake ${cmake_v}..."

check_modules

downloadPackage cmake-${cmake_v}.tar.gz

cd ${tmp}

if [ -d ${tmp}/${cmake_srcdir} ] ; then
  rm -rf ${tmp}/${cmake_srcdir}
fi

tar xvfz ${pkg}/cmake-${cmake_v}.tar.gz
cd ${tmp}/${cmake_srcdir}

./configure --prefix=${opt}/cmake-${cmake_v} \
            --parallel=${ncpu}
make -j ${ncpu} && make install
if [ ! $? -eq 0 ] ; then
  exit 4
fi

# Create the environment module
if [ -z "${MODULEPATH}" ] ; then
  source /etc/profile.d/modules.sh
fi
mkdir -pv ${MODULEPATH}/cmake
cat << eof > ${MODULEPATH}/cmake/${cmake_v}
#%Module

proc ModulesHelp { } {
   puts stderr "Puts cmake-${cmake_v} into your environment"
}

set VER ${cmake_v}
set PKG ${opt}/cmake-\$VER

module-whatis   "Loads cmake-${cmake_v}"
conflict cmake

prepend-path PATH \$PKG/bin

eof

cd ${root}
rm -rf ${tmp}/${cmake_srcdir}

}
