#!/bin/bash

# Functions for detecting and building cairo
echo 'Loading cairo...'

function get_cairo_library() {
case ${1} in
  1.16.0)
    echo libcairo.so.2.11600.0
  ;;
  *)
    echo ''
  ;;
esac
}

function cairoDepInstalled() {
if [ ! -f "${2}/lib/$(get_cairo_library ${1})" ] ; then
  return 1
else
  return 0
fi
}

function ff_check_cairo() {
echo -n "Checking for presence of cairo-${1} in ${2}..."
if cairoDepInstalled ${1} ${2}; then
  echo "present"
else
  echo "not present"
  ff_build_cairo ${1} ${2} ${3}
fi
}


function ff_build_cairo() {

# Get desired version number to install
cairo_v=${1}
if [ -z "${cairo_v}" ] ; then
  cairo_v=1.16.0
fi

case ${cairo_v} in
  1.16.0) # 2019-02-01
   cairo_package=cairo-${cairo_v}.tar.xz
   cairo_tar=xvfJ
  ;;
  *)
   echo "ERROR: Review needed for cairo ${cairo_v}"
   exit 4 # Please review
  ;;
esac

cairo_ffmpeg_ver=${3}
cairo_pixman_ver=${ffmpeg_pixman_ver}

cairo_srcdir=cairo-${cairo_v}
cairo_prefix=${2}

echo "Installing cairo-${cairo_v} in ${cairo_prefix}..."

check_modules
ff_check_pixman ${cairo_pixman_ver} ${2} ${3}

downloadPackage ${cairo_package}

cd ${tmp}

if [ -d ${tmp}/${cairo_srcdir} ] ; then
  rm -rf ${tmp}/${cairo_srcdir}
fi

cd ${tmp}
tar ${cairo_tar} ${pkg}/${cairo_package}
cd ${tmp}/${cairo_srcdir}

if [ ${debug} -gt 0 ] ; then
  echo '>> Unzip complete'
  read k
fi

module purge
module load ffmpeg-dep/${cairo_ffmpeg_ver}

config="./configure --prefix=${cairo_prefix}"

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

# The cairo tests take a long time, and are pretty finicky.
# They generate a lot of output images, and then compare to reference images.
# It can be very difficult to get 100% of the images to match against the reference
# images, and therefore this test most often results in a failure.
# Given how long it takes to complete, it may not be worth it to do.
if [ ${run_cairo_tests} -gt 0 ] ; then
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
rm -rf ${tmp}/${cairo_srcdir}
}
