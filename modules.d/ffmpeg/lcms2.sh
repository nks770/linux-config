#!/bin/bash

# Functions for detecting and building Little CMS
echo 'Loading Little CMS...'

function get_lcms2_library() {
case ${1} in
  2.9)
    echo liblcms2.so.2.0.8
  ;;
  2.10)
    echo liblcms2.so.2.0.10
  ;;
  2.11)
    echo liblcms2.so.2.0.10
  ;;
  *)
    echo ''
  ;;
esac
}

function lcms2DepInstalled() {
if [ ! -f "${2}/lib/$(get_lcms2_library ${1})" ] ; then
  return 1
else
  return 0
fi
}

function ff_check_lcms2() {
echo -n "Checking for presence of lcms2-${1} in ${2}..."
if lcms2DepInstalled ${1} ${2}; then
  echo "present"
else
  echo "not present"
  ff_build_lcms2 ${1} ${2} ${3}
fi
}

function ff_build_lcms2() {

# Get desired version number to install
lcms2_v=${1}
if [ -z "${lcms2_v}" ] ; then
  echo "ERROR: No lcms2 version specified!"
  exit 2
fi

lcms2_ffmpeg_ver=${3}

lcms2_tiff_ver=${ffmpeg_tiff_ver}
lcms2_libjpegturbo_ver=${ffmpeg_libjpegturbo_ver}
lcms2_zlib_ver=${ffmpeg_zlib_ver}

lcms2_srcdir=lcms2-${lcms2_v}
lcms2_prefix=${2}

echo "Installing lcms2-${lcms2_v} in ${lcms2_prefix}..."

check_modules
check_zlib ${lcms2_zlib_ver}
check_libjpegturbo ${lcms2_libjpegturbo_ver}
ff_check_tiff ${lcms2_tiff_ver} ${2} ${3}

downloadPackage lcms2-${lcms2_v}.tar.gz

cd ${tmp}

if [ -d ${tmp}/${lcms2_srcdir} ] ; then
  rm -rf ${tmp}/${lcms2_srcdir}
fi

cd ${tmp}
tar xvfz ${pkg}/lcms2-${lcms2_v}.tar.gz
cd ${tmp}/${lcms2_srcdir}

if [ ${debug} -gt 0 ] ; then
  echo '>> Unzip complete'
  read k
fi

module purge
module load ffmpeg-dep/${lcms2_ffmpeg_ver}
module load zlib/${lcms2_zlib_ver}
module load libjpeg-turbo/${lcms2_libjpegturbo_ver}

config="./configure --prefix=${lcms2_prefix} --with-jpeg=${opt}/libjpeg-turbo-${lcms2_libjpegturbo_ver} --with-tiff=${lcms2_prefix} LDFLAGS=-L${opt}/zlib-${lcms2_zlib_ver}/lib"
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
rm -rf ${tmp}/${lcms2_srcdir}

}
