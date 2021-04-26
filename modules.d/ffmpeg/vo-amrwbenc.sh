#!/bin/bash

# Functions for detecting and building OpenCORE Adaptive Multi Rate (AMR)

function voamrwbencInstalled() {
# Cannot evaulate if we dont have modules installed
if [ ! -f /etc/profile.d/modules.sh ] ; then
  return 1
fi
# Load modules if not loaded already
if [ -z "${MODULEPATH}" ] ; then
  source /etc/profile.d/modules.sh
fi 
# If modules is OK, then check voamrwbenc
if [ ! -f ${MODULEPATH}/vo-amrwbenc/${1} ] ; then
  return 1
else
  return 0
fi
}

function check_voamrwbenc() {
if voamrwbencInstalled ${1}; then
  echo "vo-amrwbenc ${1} is installed."
else
  build_voamrwbenc ${1}
fi
}

function build_voamrwbenc() {

# Get desired version number to install
voamrwbenc_v=${1}
if [ -z "${voamrwbenc_v}" ] ; then
  voamrwbenc_v=0.1.3
fi
voamrwbenc_srcdir=vo-amrwbenc-${voamrwbenc_v}

echo "Installing vo-amrwbenc ${voamrwbenc_v}..."

check_modules
module purge
module list

downloadPackage vo-amrwbenc-${voamrwbenc_v}.tar.gz

cd ${tmp}

if [ -d ${tmp}/${voamrwbenc_srcdir} ] ; then
  rm -rf ${tmp}/${voamrwbenc_srcdir}
fi

cd ${tmp}
tar xvfz ${pkg}/vo-amrwbenc-${voamrwbenc_v}.tar.gz
cd ${tmp}/${voamrwbenc_srcdir}

./configure --prefix=${opt}/vo-amrwbenc-${voamrwbenc_v}
make -j ${ncpu} && make install

if [ ! $? -eq 0 ] ; then
  exit 4
fi

# Create the environment module
if [ -z "${MODULEPATH}" ] ; then
  source /etc/profile.d/modules.sh
fi 
mkdir -pv ${MODULEPATH}/vo-amrwbenc
cat << eof > ${MODULEPATH}/vo-amrwbenc/${voamrwbenc_v}
#%Module

proc ModulesHelp { } {
   puts stderr "Puts voamrwbenc-${voamrwbenc_v} into your environment"
}

set VER ${voamrwbenc_v}
set PKG ${opt}/vo-amrwbenc-\$VER

module-whatis   "Loads vo-amrwbenc-${voamrwbenc_v}"
conflict voamrwbenc

prepend-path CPATH \$PKG/include
prepend-path C_INCLUDE_PATH \$PKG/include
prepend-path CPLUS_INCLUDE_PATH \$PKG/include
prepend-path LD_LIBRARY_PATH \$PKG/lib
prepend-path PKG_CONFIG_PATH \$PKG/lib/pkgconfig

eof

cd ${root}
rm -rf ${tmp}/${voamrwbenc_srcdir}

}
