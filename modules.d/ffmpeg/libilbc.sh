#!/bin/bash

# Functions for detecting and building libilbc
echo 'Loading libilbc...'

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

case ${libilbc_v} in
  2.0.2) # 2014-12-14
   libilbc_cmake_ver=3.0.2  # 2014-09-11
  ;;
  3.0.4) # 2020-12-31
   libilbc_cmake_ver=3.19.2 # 2020-12-16
  ;;
  *)
   echo "ERROR: Review needed for libilbc ${libilbc_v}"
   exit 4 # Please review
  ;;
esac

echo "Installing libilbc ${libilbc_v}..."
libilbc_srcdir=libilbc-${libilbc_v}

check_modules
check_cmake ${libilbc_cmake_ver}

downloadPackage ${libilbc_srcdir}.tar.gz

cd ${tmp}

if [ -d ${tmp}/${libilbc_srcdir} ] ; then
  rm -rf ${tmp}/${libilbc_srcdir}
fi

cd ${tmp}
tar xvfz ${pkg}/${libilbc_srcdir}.tar.gz
mkdir -pv ${tmp}/${libilbc_srcdir}/build
cd ${tmp}/${libilbc_srcdir}/build

if [ ${debug} -gt 0 ] ; then
  echo '>> Unzip complete'
  read k
fi

module purge
module load cmake/${libilbc_cmake_ver}

if [ ${debug} -gt 0 ] ; then
  echo ''
  module list
  echo cmake -L -G \"Unix Makefiles\" \
       -DCMAKE_BUILD_TYPE=Release \
       -DCMAKE_INSTALL_PREFIX=${opt}/libilbc-${libilbc_v} ..
  echo ''
  read k
fi

cmake -L -G 'Unix Makefiles' \
      -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_INSTALL_PREFIX=${opt}/libilbc-${libilbc_v} ..

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

# There is no testsuite for libilbc
#if [ ${run_tests} -gt 0 ] ; then
#  ctest
#  echo '>> Tests complete'
#  read k
#fi

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
prepend-path LD_LIBRARY_PATH \$PKG/lib
prepend-path PKG_CONFIG_PATH \$PKG/lib/pkgconfig

eof

cd ${root}
rm -rf ${tmp}/${libilbc_srcdir}

}
