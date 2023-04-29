#!/bin/bash

# Functions for detecting and building zlib
echo 'Loading zlib...'

function zlibInstalled() {
# Cannot evaulate if we dont have modules installed
if [ ! -f /etc/profile.d/modules.sh ] ; then
  return 1
fi
# Load modules if not loaded already
if [ -z "${MODULEPATH}" ] ; then
  source /etc/profile.d/modules.sh
fi 
# If modules is OK, then check zlib
if [ ! -f ${MODULEPATH}/zlib/${1} ] ; then
  return 1
else
  return 0
fi
}

function check_zlib() {
if zlibInstalled ${1}; then
  echo "zlib ${1} is installed."
else
  build_zlib ${1}
fi
}

function build_zlib() {

# Get desired version number to install
zlib_v=${1}
if [ -z "${zlib_v}" ] ; then
  zlib_v=1.2.13
fi

echo "Installing zlib ${zlib_v}..."

check_modules
module purge

downloadPackage zlib-${zlib_v}.tar.gz

cd ${tmp}

if [ -d ${tmp}/zlib-${zlib_v} ] ; then
  rm -rf ${tmp}/zlib-${zlib_v}
fi

tar xvfz ${pkg}/zlib-${zlib_v}.tar.gz
cd ${tmp}/zlib-${zlib_v}

config="./configure --prefix=${opt}/zlib-${zlib_v}"

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
  make test
  # Note 'make check' also works
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
mkdir -pv ${MODULEPATH}/zlib
cat << eof > ${MODULEPATH}/zlib/${zlib_v}
#%Module

proc ModulesHelp { } {
   puts stderr "Puts zlib-${zlib_v} into your environment"
}

set VER ${zlib_v}
set PKG ${opt}/zlib-\$VER

module-whatis   "Loads zlib-${zlib_v}"
conflict zlib

prepend-path CPATH \$PKG/include
prepend-path C_INCLUDE_PATH \$PKG/include
prepend-path CPLUS_INCLUDE_PATH \$PKG/include
prepend-path LD_LIBRARY_PATH \$PKG/lib
prepend-path MANPATH \$PKG/share/man
prepend-path PKG_CONFIG_PATH \$PKG/lib/pkgconfig

eof

cd ${root}
rm -rf ${tmp}/zlib-${zlib_v}

}
