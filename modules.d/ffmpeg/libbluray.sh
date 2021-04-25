#!/bin/bash

# Functions for detecting and building libbluray

function libblurayInstalled() {
# Cannot evaulate if we dont have modules installed
if [ ! -f /etc/profile.d/modules.sh ] ; then
  return 1
fi
# Load modules if not loaded already
if [ -z "${MODULEPATH}" ] ; then
  source /etc/profile.d/modules.sh
fi 
# If modules is OK, then check libbluray
if [ ! -f ${MODULEPATH}/libbluray/${1} ] ; then
  return 1
else
  return 0
fi
}

function check_libbluray() {
if libblurayInstalled ${1}; then
  echo "libbluray ${1} is installed."
else
  build_libbluray ${1}
fi
}

function build_libbluray() {

# Get desired version number to install
libbluray_v=${1}
if [ -z "${libbluray_v}" ] ; then
  libbluray_v=1.0.2
fi
libbluray_srcdir=libbluray-${libbluray_v}

echo "Installing libbluray ${libbluray_v}..."

check_modules
module purge
module list

downloadPackage libbluray-${libbluray_v}.tar.bz2

cd ${tmp}

if [ -d ${tmp}/${libbluray_srcdir} ] ; then
  rm -rf ${tmp}/${libbluray_srcdir}
fi

cd ${tmp}
tar xvfj ${pkg}/libbluray-${libbluray_v}.tar.bz2
cd ${tmp}/${libbluray_srcdir}

./configure --prefix=${opt}/libbluray-${libbluray_v}
make -j ${ncpu} && make install

if [ ! $? -eq 0 ] ; then
  exit 4
fi

# Create the environment module
if [ -z "${MODULEPATH}" ] ; then
  source /etc/profile.d/modules.sh
fi 
mkdir -pv ${MODULEPATH}/libbluray
cat << eof > ${MODULEPATH}/libbluray/${libbluray_v}
#%Module

proc ModulesHelp { } {
   puts stderr "Puts libbluray-${libbluray_v} into your environment"
}

set VER ${libbluray_v}
set PKG ${opt}/libbluray-\$VER

module-whatis   "Loads libbluray-${libbluray_v}"
conflict libbluray

prepend-path CPATH \$PKG/include
prepend-path C_INCLUDE_PATH \$PKG/include
prepend-path CPLUS_INCLUDE_PATH \$PKG/include
prepend-path LD_LIBRARY_PATH \$PKG/lib
prepend-path PATH \$PKG/bin
prepend-path PKG_CONFIG_PATH \$PKG/lib/pkgconfig

eof

cd ${root}
rm -rf ${tmp}/${libbluray_srcdir}

}
