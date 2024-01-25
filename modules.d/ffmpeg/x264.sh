#!/bin/bash

# Functions for detecting and building x264
echo 'Loading x264...'

function x264Installed() {
# Cannot evaulate if we dont have modules installed
if [ ! -f /etc/profile.d/modules.sh ] ; then
  return 1
fi
# Load modules if not loaded already
if [ -z "${MODULEPATH}" ] ; then
  source /etc/profile.d/modules.sh
fi 
# If modules is OK, then check x264
if [ ! -f ${MODULEPATH}/x264/${1} ] ; then
  return 1
else
  return 0
fi
}

function check_x264() {
if x264Installed ${1}; then
  echo "x264 ${1} is installed."
else
  build_x264 ${1}
fi
}

function build_x264() {

# Get desired version number to install
x264_v=${1}
if [ -z "${x264_v}" ] ; then
  x264_v=20191125
fi

echo "Installing x264 ${x264_v}..."

case ${1} in
  20191125)
   x264_srcdir=x264-1771b556ee45207f8711744ccbd5d42a3949b14c
   x264_nasm_ver=2.14.02 # 2018-12-26
  ;;
  20200425)
   x264_srcdir=x264-538f09b5b92eda0b6efe25e62fcc8542fc9f025d
   x264_nasm_ver=2.14.02 # 2018-12-26
  ;;
  20220601) # 2022-06-01
   x264_srcdir=x264-baee400fa9ced6f5481a728138fed6e867b0ff7f
   x264_nasm_ver=2.14.02 # 2018-12-26
  ;;
  *)
   echo "ERROR: Need review for x264 ${1}"
   exit 4
   ;;
esac

check_modules
check_nasm ${x264_nasm_ver}

downloadPackage x264-${x264_v}.tar.gz

cd ${tmp}

if [ -d ${tmp}/${x264_srcdir} ] ; then
  rm -rf ${tmp}/${x264_srcdir}
fi

cd ${tmp}
tar xvfz ${pkg}/x264-${x264_v}.tar.gz
cd ${tmp}/${x264_srcdir}

if [ ${debug} -gt 0 ] ; then
  echo '>> Unzip complete'
  read k
fi

config="./configure --prefix=${opt}/x264-${x264_v} \
            --enable-shared \
            --enable-static"
module purge
module load nasm/${x264_nasm_ver}

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

# x264 does not have any test suite
#if [ ${run_tests} -gt 0 ] ; then
#  make check
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
mkdir -pv ${MODULEPATH}/x264
cat << eof > ${MODULEPATH}/x264/${x264_v}
#%Module

proc ModulesHelp { } {
   puts stderr "Puts x264-${x264_v} into your environment"
}

set VER ${x264_v}
set PKG ${opt}/x264-\$VER

module-whatis   "Loads x264-${x264_v}"
conflict x264

prepend-path CPATH \$PKG/include
prepend-path C_INCLUDE_PATH \$PKG/include
prepend-path CPLUS_INCLUDE_PATH \$PKG/include
prepend-path LD_LIBRARY_PATH \$PKG/lib
prepend-path PKG_CONFIG_PATH \$PKG/lib/pkgconfig
prepend-path PATH \$PKG/bin

eof

cd ${root}
rm -rf ${tmp}/${x264_srcdir}

}
