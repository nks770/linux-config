#!/bin/bash

# Functions for detecting and building pixman
echo 'Loading pixman...'

function get_pixman_library() {
case ${1} in
  0.38.4)
    echo libpixman-1.so.0.38.4
  ;;
  *)
    echo ''
  ;;
esac
}

function pixmanDepInstalled() {
if [ ! -f "${2}/lib/$(get_pixman_library ${1})" ] ; then
  return 1
else
  return 0
fi
}

function ff_check_pixman() {
echo -n "Checking for presence of pixman-${1} in ${2}..."
if pixmanDepInstalled ${1} ${2}; then
  echo "present"
else
  echo "not present"
  ff_build_pixman ${1} ${2} ${3}
fi
}


function ff_build_pixman() {

# Get desired version number to install
pixman_v=${1}
if [ -z "${pixman_v}" ] ; then
  pixman_v=0.38.4
fi

case ${pixman_v} in
  0.38.4) # 2019-02-01
   pixman_package=pixman-${pixman_v}.tar.gz
   pixman_tar=xvfz
  ;;
  *)
   echo "ERROR: Review needed for pixman ${pixman_v}"
   exit 4 # Please review
  ;;
esac

pixman_ffmpeg_ver=${3}
pixman_libpng_ver=${ffmpeg_libpng_ver}

pixman_srcdir=pixman-${pixman_v}
pixman_prefix=${2}

echo "Installing pixman-${pixman_v} in ${pixman_prefix}..."

check_modules
check_libpng ${pixman_libpng_ver}

downloadPackage ${pixman_package}

cd ${tmp}

if [ -d ${tmp}/${pixman_srcdir} ] ; then
  rm -rf ${tmp}/${pixman_srcdir}
fi

cd ${tmp}
tar ${pixman_tar} ${pkg}/${pixman_package}
cd ${tmp}/${pixman_srcdir}

if [ ${debug} -gt 0 ] ; then
  echo '>> Unzip complete'
  read k
fi

module purge
module load ffmpeg-dep/${pixman_ffmpeg_ver}
module load libpng/${pixman_libpng_ver}

config="./configure --enable-libpng --prefix=${pixman_prefix}"

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

cd ${root}
rm -rf ${tmp}/${pixman_srcdir}
}
