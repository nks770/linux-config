#!/bin/bash

# Functions for detecting and building libvpx
echo 'Loading libvpx...'

function libvpxInstalled() {
# Cannot evaulate if we dont have modules installed
if [ ! -f /etc/profile.d/modules.sh ] ; then
  return 1
fi
# Load modules if not loaded already
if [ -z "${MODULEPATH}" ] ; then
  source /etc/profile.d/modules.sh
fi 
# If modules is OK, then check libvpx
if [ ! -f ${MODULEPATH}/libvpx/${1} ] ; then
  return 1
else
  return 0
fi
}

function check_libvpx() {
if libvpxInstalled ${1}; then
  echo "libvpx ${1} is installed."
else
  build_libvpx ${1}
fi
}

function build_libvpx() {

# Get desired version number to install
libvpx_v=${1}
if [ -z "${libvpx_v}" ] ; then
  libvpx_v=1.8.2
fi

case ${libvpx_v} in
  1.8.2) # Dec 19, 2019
   libvpx_yasm_ver=1.3.0 # August 10, 2014
  ;;
  *)
   echo "ERROR: Need review for libvpx ${libvpx_v}"
   exit 4
   ;;
esac

echo "Installing libvpx ${libvpx_v}..."
libvpx_srcdir=libvpx-${libvpx_v}

check_modules
check_yasm ${libvpx_yasm_ver}

downloadPackage libvpx-${libvpx_v}.tar.gz

cd ${tmp}

if [ -d ${tmp}/${libvpx_srcdir} ] ; then
  rm -rf ${tmp}/${libvpx_srcdir}
fi

cd ${tmp}
tar xvfz ${pkg}/libvpx-${libvpx_v}.tar.gz
cd ${tmp}/${libvpx_srcdir}

if [ ${debug} -gt 0 ] ; then
  echo '>> Unzip complete'
  read k
fi

module purge
module load yasm/${libvpx_yasm_ver}

config="./configure --prefix=${opt}/libvpx-${libvpx_v} \
            --enable-shared \
            --enable-vp8 \
            --enable-vp9"
if [ ${debug} -gt 0 ] ; then
  ./configure --help
  echo ''
  module list
  echo ''
  echo ${config}
  read k
fi

${config}

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

# libvpx has a testsuite, but it attemps to download a lot of data from the web
#if [ ${run_tests} -gt 0 ] ; then
#  make test
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
mkdir -pv ${MODULEPATH}/libvpx
cat << eof > ${MODULEPATH}/libvpx/${libvpx_v}
#%Module

proc ModulesHelp { } {
   puts stderr "Puts libvpx-${libvpx_v} into your environment"
}

set VER ${libvpx_v}
set PKG ${opt}/libvpx-\$VER

module-whatis "Loads libvpx-${libvpx_v}"
conflict libvpx

prepend-path CPATH \$PKG/include
prepend-path C_INCLUDE_PATH \$PKG/include
prepend-path CPLUS_INCLUDE_PATH \$PKG/include
prepend-path LD_LIBRARY_PATH \$PKG/lib
prepend-path PKG_CONFIG_PATH \$PKG/lib/pkgconfig
prepend-path PATH \$PKG/bin

eof

cd ${root}
rm -rf ${tmp}/${libvpx_srcdir}

}
