#!/bin/bash

# Functions for detecting and building libsvtav1
echo 'Loading libsvtav1...'

function get_libsvtav1_library() {
case ${1} in
  0.8.6)
    echo libSvtAv1Enc.so.0.8.6
  ;;
  *)
    echo ''
  ;;
esac
}

function libsvtav1Installed() {
# Cannot evaulate if we dont have modules installed
if [ ! -f /etc/profile.d/modules.sh ] ; then
  return 1
fi
# Load modules if not loaded already
if [ -z "${MODULEPATH}" ] ; then
  source /etc/profile.d/modules.sh
fi 
# If modules is OK, then check libsvtav1
if [ ! -f ${MODULEPATH}/libsvtav1/${1} ] ; then
  return 1
else
  return 0
fi
}

function check_libsvtav1() {
if libsvtav1Installed ${1}; then
  echo "libsvtav1 ${1} is installed."
else
  build_libsvtav1 ${1}
fi
}

function build_libsvtav1() {

# Get desired version number to install
libsvtav1_v=${1}
if [ -z "${libsvtav1_v}" ] ; then
  echo "ERROR: No libsvtav1 version specified!"
  exit 2
fi

case ${libsvtav1_v} in
0.8.6) # 2020-11-29
   libsvtav1_srcdir=SVT-AV1-v${libsvtav1_v}
   libsvtav1_cmake_ver=3.19.1    # 2020-11-24
   libsvtav1_nasm_ver=2.15.05    # 2020-08-28
   ;;
*)
   echo "ERROR: Need review for libsvtav1 ${libsvtav1_v}"
   exit 4
   ;;
esac

echo "Installing libsvtav1 ${libsvtav1_v}..."

check_modules
check_cmake ${libsvtav1_cmake_ver}
check_nasm ${libsvtav1_nasm_ver}

downloadPackage ${libsvtav1_srcdir}.tar.gz

cd ${tmp}

if [ -d ${tmp}/${libsvtav1_srcdir} ] ; then
  rm -rf ${tmp}/${libsvtav1_srcdir}
fi

cd ${tmp}
tar xvfz ${pkg}/${libsvtav1_srcdir}.tar.gz
cd ${tmp}/${libsvtav1_srcdir}/Build/linux

if [ ${debug} -gt 0 ] ; then
  echo '>> Unzip complete'
  read k
fi

module purge
module load cmake/${libsvtav1_cmake_ver}
module load nasm/${libsvtav1_nasm_ver}

if [ ${debug} -gt 0 ] ; then
  echo ''
  module list
  echo cmake -L -G \"Unix Makefiles\" \
       -DCMAKE_BUILD_TYPE=Release \
       -DENABLE_NASM=ON \
       -DBUILD_SHARED_LIBS=ON \
       -DCMAKE_INSTALL_PREFIX=${opt}/libsvtav1-${libsvtav1_v} ../..
  echo ''
  read k
fi

cmake -L -G "Unix Makefiles" \
       -DCMAKE_BUILD_TYPE=Release \
       -DENABLE_NASM=ON \
       -DBUILD_SHARED_LIBS=ON \
       -DCMAKE_INSTALL_PREFIX=${opt}/libsvtav1-${libsvtav1_v} ../..

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
mkdir -pv ${MODULEPATH}/libsvtav1
cat << eof > ${MODULEPATH}/libsvtav1/${libsvtav1_v}
#%Module

proc ModulesHelp { } {
   puts stderr "Puts libsvtav1-${libsvtav1_v} into your environment"
}

set VER ${libsvtav1_v}
set PKG ${opt}/libsvtav1-\$VER

module-whatis   "Loads libsvtav1-${libsvtav1_v}"
conflict libsvtav1

prepend-path PATH \$PKG/bin
prepend-path CPATH \$PKG/include
prepend-path C_INCLUDE_PATH \$PKG/include
prepend-path CPLUS_INCLUDE_PATH \$PKG/include
prepend-path LD_LIBRARY_PATH \$PKG/lib
prepend-path PKG_CONFIG_PATH \$PKG/lib/pkgconfig

eof

cd ${root}
rm -rf ${tmp}/${libsvtav1_srcdir}

}
