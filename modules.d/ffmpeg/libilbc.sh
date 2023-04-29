#!/bin/bash

# Functions for detecting and building libilbc

function libilbcInstalled() {
# Cannot evaulate if we dont have modules installed
if [ ! -f /etc/profile.d/modules.sh ] ; then
  return 1
fi
# Load modules if not loaded already
if [ -z "${MODULEPATH}" ] ; then
  source /etc/profile.d/modules.sh
fi 
# If modules is OK, then check libilbc
if [ ! -f ${MODULEPATH}/libilbc/${1} ] ; then
  return 1
else
  return 0
fi
}

function check_libilbc() {
if libilbcInstalled ${1}; then
  echo "libilbc ${1} is installed."
else
  build_libilbc ${1}
fi
}

function build_libilbc() {

# Get desired version number to install
libilbc_v=${1}
if [ -z "${libilbc_v}" ] ; then
  libilbc_v=2.0.2
fi
libilbc_srcdir=libilbc-${libilbc_v}

echo "Installing libilbc ${libilbc_v}..."

case ${1} in
  2.0.2)
   libilbc_cmake_ver=3.9.6  # 2017-11-10
  ;;
  3.0.4) # 2020-12-31
   libilbc_cmake_ver=3.18.5 # 2020-11-18
  ;;
esac

check_modules
check_cmake ${libilbc_cmake_ver}

module purge
module load cmake/${libilbc_cmake_ver}
module list

downloadPackage libilbc-${libilbc_v}.tar.gz

cd ${tmp}

if [ -d ${tmp}/${libilbc_srcdir} ] ; then
  rm -rf ${tmp}/${libilbc_srcdir}
fi

cd ${tmp}
tar xvfz ${pkg}/libilbc-${libilbc_v}.tar.gz
cd ${tmp}/${libilbc_srcdir}

cmake -G 'Unix Makefiles' -DCMAKE_INSTALL_PREFIX=${opt}/libilbc-${1}
make -j ${ncpu} && make install

if [ ! $? -eq 0 ] ; then
  exit 4
fi

# Create the environment module
if [ -z "${MODULEPATH}" ] ; then
  source /etc/profile.d/modules.sh
fi 
mkdir -pv ${MODULEPATH}/libilbc
cat << eof > ${MODULEPATH}/libilbc/${libilbc_v}
#%Module

proc ModulesHelp { } {
   puts stderr "Puts libilbc-${libilbc_v} into your environment"
}

set VER ${libilbc_v}
set PKG ${opt}/libilbc-\$VER

module-whatis   "Loads libilbc-${libilbc_v}"
conflict libilbc

prepend-path CPATH \$PKG/include
prepend-path C_INCLUDE_PATH \$PKG/include
prepend-path CPLUS_INCLUDE_PATH \$PKG/include
prepend-path LD_LIBRARY_PATH \$PKG/lib64
prepend-path PKG_CONFIG_PATH \$PKG/lib64/pkgconfig

eof

cd ${root}
rm -rf ${tmp}/${libilbc_srcdir}

}
