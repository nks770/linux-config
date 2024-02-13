#!/bin/bash

# Functions for detecting and building vidstab
echo 'Loading vidstab...'

function vidstabInstalled() {
# Cannot evaulate if we dont have modules installed
if [ ! -f /etc/profile.d/modules.sh ] ; then
  return 1
fi
# Load modules if not loaded already
if [ -z "${MODULEPATH}" ] ; then
  source /etc/profile.d/modules.sh
fi 
# If modules is OK, then check vidstab
if [ ! -f ${MODULEPATH}/vidstab/${1} ] ; then
  return 1
else
  return 0
fi
}

function check_vidstab() {
if vidstabInstalled ${1}; then
  echo "vidstab ${1} is installed."
else
  build_vidstab ${1}
fi
}

function build_vidstab() {

# Get desired version number to install
vidstab_v=${1}
if [ -z "${vidstab_v}" ] ; then
  echo "ERROR: No vidstab version specified!"
  exit 2
fi

case ${vidstab_v} in
  1.1.0 ) # 2017-05-30
   vidstab_cmake_ver=3.8.1  # 2017-05-02
  ;;
  1.1.1 ) # 2020-05-30
   vidstab_cmake_ver=3.17.3 # 2020-05-28
  ;;
  *)
   echo "ERROR: Review needed for vidstab ${vidstab_v}"
   exit 4 # Please review
  ;;
esac

echo "Installing vidstab ${vidstab_v}..."
vidstab_srcdir=vid.stab-${vidstab_v}
vidstab_prefix=${opt}/vidstab-${vidstab_v}

check_modules
check_cmake ${vidstab_cmake_ver}

downloadPackage ${vidstab_srcdir}.tar.gz

cd ${tmp}

if [ -d ${tmp}/${vidstab_srcdir} ] ; then
  rm -rf ${tmp}/${vidstab_srcdir}
fi

cd ${tmp}
tar xvfz ${pkg}/${vidstab_srcdir}.tar.gz
mkdir -pv ${tmp}/${vidstab_srcdir}/build

if [ ${debug} -gt 0 ] ; then
  echo '>> Unzip complete'
  read k
fi

cd ${tmp}/${vidstab_srcdir}/build

module purge
module load cmake/${vidstab_cmake_ver}

if [ ${debug} -gt 0 ] ; then
  echo ''
  module list
  echo ''
  echo cmake -L -G \"Unix Makefiles\" \
      -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_INSTALL_PREFIX=${vidstab_prefix} ..
  read k
fi

cmake -L -G "Unix Makefiles" \
      -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_INSTALL_PREFIX=${vidstab_prefix} ..

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

# There is no test suite for vidstab
#if [ ${run_tests} -gt 0 ] ; then
#  ctest
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
mkdir -pv ${MODULEPATH}/vidstab
cat << eof > ${MODULEPATH}/vidstab/${vidstab_v}
#%Module

proc ModulesHelp { } {
   puts stderr "Puts vidstab-${vidstab_v} into your environment"
}

set VER ${vidstab_v}
set PKG ${opt}/vidstab-\$VER

module-whatis   "Loads vidstab-${vidstab_v}"
conflict vidstab

prepend-path CPATH \$PKG/include
prepend-path C_INCLUDE_PATH \$PKG/include
prepend-path CPLUS_INCLUDE_PATH \$PKG/include
prepend-path LD_LIBRARY_PATH \$PKG/lib
prepend-path PKG_CONFIG_PATH \$PKG/lib/pkgconfig

eof

cd ${root}
rm -rf ${tmp}/${vidstab_srcdir}

}
