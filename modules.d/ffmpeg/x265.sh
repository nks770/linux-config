#!/bin/bash

# Functions for detecting and building x265
echo 'Loading x265...'

function x265Installed() {
# Cannot evaulate if we dont have modules installed
if [ ! -f /etc/profile.d/modules.sh ] ; then
  return 1
fi
# Load modules if not loaded already
if [ -z "${MODULEPATH}" ] ; then
  source /etc/profile.d/modules.sh
fi 
# If modules is OK, then check x265
if [ ! -f ${MODULEPATH}/x265/${1} ] ; then
  return 1
else
  return 0
fi
}

function check_x265() {
if x265Installed ${1}; then
  echo "x265 ${1} is installed."
else
  build_x265 ${1}
fi
}

function build_x265() {

# Get desired version number to install
x265_v=${1}
if [ -z "${x265_v}" ] ; then
  x265_v=3.2.1
fi

case ${x265_v} in
  3.2.1) # Oct 22, 2019
   x265_cmake_ver=3.14.7 # 2019-10-02 10:48
   x265_nasm_ver=2.14.02 # 2018-12-26 05:44
  ;;
  3.4) # May 29, 2020
   x265_cmake_ver=3.17.3 # 2020-05-28 08:21
   x265_nasm_ver=2.14.02 # 2018-12-26 05:44
  ;;
  *)
   echo "ERROR: Need review for x265 ${x265_v}"
   exit 4
   ;;
esac

## Optimized dependency strategy
#if [ "${dependency_strategy}" == "optimized" ] ; then
#  cmake_ver=${global_cmake}
#fi

echo "Installing x265 ${x265_v}..."

x265_srcdir=x265-${x265_v}

check_modules
check_cmake ${x265_cmake_ver}
check_nasm ${x265_nasm_ver}

downloadPackage x265-${x265_v}.tar.gz

cd ${tmp}

if [ -d ${tmp}/${x265_srcdir} ] ; then
  rm -rf ${tmp}/${x265_srcdir}
fi

cd ${tmp}
tar xvfz ${pkg}/x265-${x265_v}.tar.gz
cd ${tmp}/${x265_srcdir}/build/linux

if [ ${debug} -gt 0 ] ; then
  echo '>> Unzip complete'
  read k
fi

module purge
module load nasm/${x265_nasm_ver}
module load cmake/${x265_cmake_ver}

if [ ${debug} -gt 0 ] ; then
  #cmake -L -DPYTHON_EXECUTABLE:FILEPATH=$(which python3) ..
  echo ''
  module list
  echo ''
  echo cmake -L -G \"Unix Makefiles\" \
      -DCMAKE_INSTALL_PREFIX=${opt}/x265-${x265_v} \
      ../../source
  read k
fi

cmake -L -G 'Unix Makefiles' \
-DCMAKE_INSTALL_PREFIX=${opt}/x265-${x265_v} \
../../source
#-DPYTHON_EXECUTABLE:FILEPATH=$(which python3) \

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

# x265 does not have any test suite
#if [ ${run_tests} -gt 0 ] ; then
#  make check
#  echo ''
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
mkdir -pv ${MODULEPATH}/x265
cat << eof > ${MODULEPATH}/x265/${x265_v}
#%Module

proc ModulesHelp { } {
   puts stderr "Puts x265-${x265_v} into your environment"
}

set VER ${x265_v}
set PKG ${opt}/x265-\$VER

module-whatis   "Loads x265-${x265_v}"
conflict x265

prepend-path CPATH \$PKG/include
prepend-path C_INCLUDE_PATH \$PKG/include
prepend-path CPLUS_INCLUDE_PATH \$PKG/include
prepend-path LD_LIBRARY_PATH \$PKG/lib
prepend-path PKG_CONFIG_PATH \$PKG/lib/pkgconfig
prepend-path PATH \$PKG/bin

eof

cd ${root}
rm -rf ${tmp}/${x265_srcdir}

}
