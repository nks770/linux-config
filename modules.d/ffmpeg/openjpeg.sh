#!/bin/bash

# Functions for detecting and building openjpeg
echo 'Loading openjpeg...'

function get_openjpeg_library() {
case ${1} in
  2.3.1)
    echo libopenjp2.so.2.3.1
  ;;
  *)
    echo ''
  ;;
esac
}

function openjpegDepInstalled() {
if [ ! -f "${2}/lib/$(get_openjpeg_library ${1})" ] ; then
  return 1
else
  return 0
fi
}

function ff_check_openjpeg() {
echo -n "Checking for presence of openjpeg-${1} in ${2}..."
if openjpegDepInstalled ${1} ${2}; then
  echo "present"
else
  echo "not present"
  ff_build_openjpeg ${1} ${2} ${3}
fi
}

function ff_build_openjpeg() {

# Get desired version number to install
openjpeg_v=${1}
if [ -z "${openjpeg_v}" ] ; then
  echo "ERROR: No OpenJPEG version specified!"
  exit 2
fi

case ${openjpeg_v} in
  1.5.2) # 2014-03-28
   openjpeg_cmake_ver=2.8.12.2 # 2014-01-16
   openjpeg_doxygen_ver=1.8.6  # 2013-12-24
  ;;
  2.3.1) # Apr 2, 2019
   openjpeg_cmake_ver=3.13.4   # 2019-02-01 13:20
   openjpeg_doxygen_ver=1.8.15 # 2018-12-27
  ;;
  2.5.0) # May 13, 2022
   openjpeg_cmake_ver=3.23.1  # 2022-04-12 10:55
   openjpeg_doxygen_ver=1.9.4 # 2022-05-05
  ;;
  *)
   echo "ERROR: Review needed for openjpeg ${openjpeg_v}"
   exit 4 # Please review
  ;;
esac

openjpeg_ffmpeg_ver=${3}

openjpeg_zlib_ver=${ffmpeg_zlib_ver}
openjpeg_libpng_ver=${ffmpeg_libpng_ver}
openjpeg_tiff_ver=${ffmpeg_tiff_ver}
openjpeg_lcms2_ver=${ffmpeg_lcms2_ver}

openjpeg_zlib_lib=$(get_zlib_library ${openjpeg_zlib_ver})
openjpeg_libpng_lib=$(get_libpng_library ${openjpeg_libpng_ver})
openjpeg_tiff_lib=$(get_tiff_library ${openjpeg_tiff_ver})
openjpeg_lcms2_lib=$(get_lcms2_library ${openjpeg_lcms2_ver})

openjpeg_srcdir=openjpeg-${openjpeg_v}
openjpeg_prefix=${2}

echo "Installing openjpeg-${openjpeg_v} in ${openjpeg_prefix}..."

check_modules
check_cmake ${openjpeg_cmake_ver}
check_zlib ${openjpeg_zlib_ver}
check_libpng ${openjpeg_libpng_ver}
check_doxygen ${openjpeg_doxygen_ver}
ff_check_tiff ${openjpeg_tiff_ver} ${2} ${3}
ff_check_lcms2 ${openjpeg_lcms2_ver} ${2} ${3}

downloadPackage openjpeg-${openjpeg_v}.tar.gz

cd ${tmp}

if [ -d ${tmp}/${openjpeg_srcdir} ] ; then
  rm -rf ${tmp}/${openjpeg_srcdir}
fi

cd ${tmp}
tar xvfz ${pkg}/openjpeg-${openjpeg_v}.tar.gz
mkdir -pv ${tmp}/${openjpeg_srcdir}/build
cd ${tmp}/${openjpeg_srcdir}/build

if [ ${debug} -gt 0 ] ; then
  echo '>> Unzip complete'
  read k
fi

module purge
module load ffmpeg-dep/${openjpeg_ffmpeg_ver}
module load cmake/${openjpeg_cmake_ver}
module load zlib/${openjpeg_zlib_ver}
module load libpng/${openjpeg_libpng_ver}
module load doxygen/${openjpeg_doxygen_ver}

if [ ${debug} -gt 0 ] ; then
  echo ''
  module list
  echo cmake -L -G \"Unix Makefiles\" \
       -DZLIB_LIBRARY=${opt}/zlib-${openjpeg_zlib_ver}/lib/${openjpeg_zlib_lib} \
       -DZLIB_INCLUDE_DIR=${opt}/zlib-${openjpeg_zlib_ver}/include \
       -DPNG_LIBRARY=${opt}/libpng-${openjpeg_libpng_ver}/lib/${openjpeg_libpng_lib} \
       -DPNG_PNG_INCLUDE_DIR=${opt}/libpng-${openjpeg_libpng_ver}/include \
       -DTIFF_LIBRARY=${openjpeg_prefix}/lib/${openjpeg_tiff_lib} \
       -DTIFF_INCLUDE_DIR=${openjpeg_prefix}/include \
       -DLCMS2_LIBRARY=${openjpeg_prefix}/lib/${openjpeg_lcms2_lib} \
       -DLCMS2_INCLUDE_DIR=${openjpeg_prefix}/include \
       -DBUILD_DOC=ON \
       -DCMAKE_INSTALL_PREFIX=${openjpeg_prefix} ..
  echo ''
  read k
fi

cmake -L -G 'Unix Makefiles' \
       -DZLIB_LIBRARY=${opt}/zlib-${openjpeg_zlib_ver}/lib/${openjpeg_zlib_lib} \
       -DZLIB_INCLUDE_DIR=${opt}/zlib-${openjpeg_zlib_ver}/include \
       -DPNG_LIBRARY=${opt}/libpng-${openjpeg_libpng_ver}/lib/${openjpeg_libpng_lib} \
       -DPNG_PNG_INCLUDE_DIR=${opt}/libpng-${openjpeg_libpng_ver}/include \
       -DTIFF_LIBRARY=${openjpeg_prefix}/lib/${openjpeg_tiff_lib} \
       -DTIFF_INCLUDE_DIR=${openjpeg_prefix}/include \
       -DLCMS2_LIBRARY=${openjpeg_prefix}/lib/${openjpeg_lcms2_lib} \
       -DLCMS2_INCLUDE_DIR=${openjpeg_prefix}/include \
       -DBUILD_DOC=ON \
       -DCMAKE_INSTALL_PREFIX=${openjpeg_prefix} ..

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

## openjpeg does not appear to have a test suite
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

cd ${root}
rm -rf ${tmp}/${openjpeg_srcdir}

}
