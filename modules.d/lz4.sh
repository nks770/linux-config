#!/bin/bash

# Functions for detecting and building lz4
echo 'Loading lz4...'

function get_lz4_library() {
case ${1} in
  1.9.4)
    echo liblz4.so.1.9.4
  ;;
  *)
    echo ''
  ;;
esac
}

function lz4Installed() {
# Cannot evaulate if we dont have modules installed
if [ ! -f /etc/profile.d/modules.sh ] ; then
  return 1
fi
# Load modules if not loaded already
if [ -z "${MODULEPATH}" ] ; then
  source /etc/profile.d/modules.sh
fi 
# If modules is OK, then check lz4
if [ ! -f ${MODULEPATH}/lz4/${1} ] ; then
  return 1
else
  return 0
fi
}

function check_lz4() {
if lz4Installed ${1}; then
  echo "lz4 ${1} is installed."
else
  build_lz4 ${1}
fi
}

function build_lz4() {

lz4_use_cmake=0

# Get desired version number to install
lz4_v=${1}
if [ -z "${lz4_v}" ] ; then
  lz4_v=1.9.4
fi

case ${lz4_v} in
  1.9.2) # 2019-08-15
    lz4_cmake_ver=3.15.2 # 2019-08-07
  ;;
  1.9.3) # 2020-11-15
    lz4_cmake_ver=3.18.4 # 2020-10-06
  ;;
  1.9.4) # 2022-08-15
    lz4_cmake_ver=3.24.0 # 2022-08-04
  ;;
  *)
   echo "ERROR: Review needed for lz4 ${lz4_v}"
   exit 4 # Please review
  ;;
esac

echo "Installing lz4 ${lz4_v}..."
lz4_srcdir=lz4-${lz4_v}

check_modules
if [ ${lz4_use_cmake} -gt 0 ] ; then
  check_cmake ${lz4_cmake_ver}
fi

downloadPackage lz4-${lz4_v}.tar.gz

cd ${tmp}

if [ -d ${tmp}/${lz4_srcdir} ] ; then
  rm -rf ${tmp}/${lz4_srcdir}
fi

cd ${tmp}
tar xvfz ${pkg}/lz4-${lz4_v}.tar.gz
cd ${tmp}/${lz4_srcdir}

if [ ${debug} -gt 0 ] ; then
  echo '>> Unzip complete'
  read k
fi

module purge
if [ ${lz4_use_cmake} -gt 0 ] ; then
  module load cmake/${lz4_cmake_ver}
fi

if [ ${lz4_use_cmake} -gt 0 ] ; then

cd ${tmp}/${lz4_srcdir}/build

if [ ${debug} -gt 0 ] ; then
  echo ''
  module list
  echo cmake -L -G \"Unix Makefiles\" \
       -DCMAKE_INSTALL_PREFIX=${opt}/lz4-${lz4_v} \
       -DBUILD_STATIC_LIBS=ON cmake
  echo ''
  read k
fi

cmake -L -G 'Unix Makefiles' \
       -DCMAKE_INSTALL_PREFIX=${opt}/lz4-${lz4_v} \
       -DBUILD_STATIC_LIBS=ON cmake

else
  if [ ${debug} -gt 0 ] ; then
    echo ''
    module list
    echo ''
    echo 'No configuration is necessary.'
    echo ''
  fi
fi

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
  make check
  echo '>> Check complete'
  read k
  make test
  echo '>> Tests complete'
  read k
fi

if [ ${lz4_use_cmake} -gt 0 ] ; then
  make install
else
  make prefix=${opt}/lz4-${lz4_v} install
fi

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
mkdir -pv ${MODULEPATH}/lz4
cat << eof > ${MODULEPATH}/lz4/${lz4_v}
#%Module

proc ModulesHelp { } {
   puts stderr "Puts lz4-${lz4_v} into your environment"
}

set VER ${lz4_v}
set PKG ${opt}/lz4-\$VER

module-whatis   "Loads lz4-${lz4_v}"
conflict lz4

prepend-path PATH \$PKG/bin
prepend-path CPATH \$PKG/include
prepend-path C_INCLUDE_PATH \$PKG/include
prepend-path CPLUS_INCLUDE_PATH \$PKG/include
prepend-path LD_LIBRARY_PATH \$PKG/lib
prepend-path MANPATH \$PKG/share/man
prepend-path PKG_CONFIG_PATH \$PKG/lib/pkgconfig

eof

cd ${root}
rm -rf ${tmp}/${lz4_srcdir}

}
