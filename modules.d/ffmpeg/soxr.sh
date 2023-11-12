#!/bin/bash

# Functions for detecting and building soxr
echo 'Loading soxr...'

function soxrInstalled() {
# Cannot evaulate if we dont have modules installed
if [ ! -f /etc/profile.d/modules.sh ] ; then
  return 1
fi
# Load modules if not loaded already
if [ -z "${MODULEPATH}" ] ; then
  source /etc/profile.d/modules.sh
fi 
# If modules is OK, then check soxr
if [ ! -f ${MODULEPATH}/soxr/${1} ] ; then
  return 1
else
  return 0
fi
}

function check_soxr() {
if soxrInstalled ${1}; then
  echo "soxr ${1} is installed."
else
  build_soxr ${1}
fi
}

function build_soxr() {

# Get desired version number to install
soxr_v=${1}
if [ -z "${soxr_v}" ] ; then
  echo "ERROR: No soxr version specified!"
  exit 2
fi

case ${soxr_v} in
  0.1.3 ) # 2018-02-24
   soxr_cmake_ver=3.10.2  # 2018-01-18
  ;;
  *)
   echo "ERROR: Review needed for soxr ${soxr_v}"
   exit 4 # Please review
  ;;
esac

echo "Installing soxr ${soxr_v}..."
soxr_srcdir=soxr-${soxr_v}-Source
soxr_prefix=${opt}/soxr-${soxr_v}

check_modules
check_cmake ${soxr_cmake_ver}

downloadPackage ${soxr_srcdir}.tar.xz

cd ${tmp}

if [ -d ${tmp}/${soxr_srcdir} ] ; then
  rm -rf ${tmp}/${soxr_srcdir}
fi

cd ${tmp}
tar xvfJ ${pkg}/${soxr_srcdir}.tar.xz
mkdir -pv ${tmp}/${soxr_srcdir}/Release

if [ ${debug} -gt 0 ] ; then
  echo '>> Unzip complete'
  read k
fi

cd ${tmp}/${soxr_srcdir}/Release

module purge
module load cmake/${soxr_cmake_ver}

if [ ${debug} -gt 0 ] ; then
  echo ''
  module list
  echo ''
  echo cmake -L \
      -Wno-dev \
      -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_INSTALL_PREFIX=${soxr_prefix} ..
  read k
fi

# Prevent interference from any in-tree build
rm -fv ${tmp}/${soxr_srcdir}/CMakeCache.txt

cmake -L \
      -Wno-dev \
      -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_INSTALL_PREFIX=${soxr_prefix} ..

if [ ${debug} -gt 0 ] ; then
  echo '>> Configure complete'
  read k
fi

make
#make -j ${ncpu}

if [ ! $? -eq 0 ] ; then
  exit 4
fi
if [ ${debug} -gt 0 ] ; then
  echo '>> Build complete'
  read k
fi

if [ ${run_tests} -gt 0 ] ; then
  ctest || echo "FAILURE details in ${tmp}/${soxr_srcdir}/Testing/Temporary/LastTest.log"
  echo ''
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
mkdir -pv ${MODULEPATH}/soxr
cat << eof > ${MODULEPATH}/soxr/${soxr_v}
#%Module

proc ModulesHelp { } {
   puts stderr "Puts soxr-${soxr_v} into your environment"
}

set VER ${soxr_v}
set PKG ${opt}/soxr-\$VER

module-whatis   "Loads soxr-${soxr_v}"
conflict soxr

prepend-path CPATH \$PKG/include
prepend-path C_INCLUDE_PATH \$PKG/include
prepend-path CPLUS_INCLUDE_PATH \$PKG/include
prepend-path LD_LIBRARY_PATH \$PKG/lib
prepend-path PKG_CONFIG_PATH \$PKG/lib/pkgconfig

eof

cd ${root}
rm -rf ${tmp}/${soxr_srcdir}

}
