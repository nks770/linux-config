#!/bin/bash

# Functions for detecting and building libuuid
echo 'Loading libuuid...'

function libuuidInstalled() {
# Cannot evaulate if we dont have modules installed
if [ ! -f /etc/profile.d/modules.sh ] ; then
  return 1
fi
# Load modules if not loaded already
if [ -z "${MODULEPATH}" ] ; then
  source /etc/profile.d/modules.sh
fi 
# If modules is OK, then check libuuid
if [ ! -f ${MODULEPATH}/libuuid/${1} ] ; then
  return 1
else
  return 0
fi
}

function check_libuuid() {
if libuuidInstalled ${1}; then
  echo "libuuid ${1} is installed."
else
  build_libuuid ${1}
fi
}

function build_libuuid() {

# Get desired version number to install
libuuid_v=${1}
if [ -z "${libuuid_v}" ] ; then
  libuuid_v=1.0.3
fi

echo "Installing libuuid ${libuuid_v}..."

check_modules
module purge

downloadPackage libuuid-${libuuid_v}.tar.gz

cd ${tmp}

if [ -d ${tmp}/libuuid-${libuuid_v} ] ; then
  rm -rf ${tmp}/libuuid-${libuuid_v}
fi

tar xvfz ${pkg}/libuuid-${libuuid_v}.tar.gz
cd ${tmp}/libuuid-${libuuid_v}

config="./configure --prefix=${opt}/libuuid-${libuuid_v}"

if [ ${debug} -gt 0 ] ; then
  ./configure --help
  echo
  echo ${config}
  read k
fi

${config}

if [ ${debug} -gt 0 ] ; then
  echo '>> Configure complete'
  read k
fi

#make -j ${ncpu}
make

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
mkdir -pv ${MODULEPATH}/libuuid
cat << eof > ${MODULEPATH}/libuuid/${libuuid_v}
#%Module

proc ModulesHelp { } {
   puts stderr "Puts libuuid-${libuuid_v} into your environment"
}

set VER ${libuuid_v}
set PKG ${opt}/libuuid-\$VER

module-whatis   "Loads libuuid-${libuuid_v}"
conflict libuuid

prepend-path CPATH \$PKG/include
prepend-path C_INCLUDE_PATH \$PKG/include
prepend-path CPLUS_INCLUDE_PATH \$PKG/include
prepend-path LD_LIBRARY_PATH \$PKG/lib
prepend-path PKG_CONFIG_PATH \$PKG/lib/pkgconfig

eof

cd ${root}
rm -rf ${tmp}/libuuid-${libuuid_v}

}
