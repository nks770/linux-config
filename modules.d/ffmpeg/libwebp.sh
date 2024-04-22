#!/bin/bash

# Functions for detecting and building libwebp
echo 'Loading libwebp...'

function get_libwebp_library() {
case ${1} in
  1.0.3)
    echo libwebp.so.7.0.5
  ;;
  1.1.0)
    echo libwebp.so.7.1.0
  ;;
  1.2.0)
    echo libwebp.so.7.1.1
  ;;
  *)
    echo ''
  ;;
esac
}

function libwebpDepInstalled() {
if [ ! -f "${2}/lib/$(get_libwebp_library ${1})" ] ; then
  return 1
else
  return 0
fi
}

function ff_check_libwebp() {
echo -n "Checking for presence of libwebp-${1} in ${2}..."
if libwebpDepInstalled ${1} ${2}; then
  echo "present"
else
  echo "not present"
  ff_build_libwebp ${1} ${2} ${3}
fi
}

function ff_build_libwebp() {

# Get desired version number to install
libwebp_v=${1}
if [ -z "${libwebp_v}" ] ; then
  echo "ERROR: No libwebp version specified!"
  exit 2
fi

libwebp_ffmpeg_ver=${3}

libwebp_libjpegturbo_ver=${ffmpeg_libjpegturbo_ver}
libwebp_tiff_ver=${ffmpeg_tiff_ver}
libwebp_giflib_ver=${ffmpeg_giflib_ver}
libwebp_libpng_ver=${ffmpeg_libpng_ver}

libwebp_srcdir=libwebp-${libwebp_v}
libwebp_prefix=${2}

echo "Installing libwebp-${libwebp_v} in ${libwebp_prefix}..."

check_modules
check_libjpegturbo ${libwebp_libjpegturbo_ver}
check_giflib ${libwebp_giflib_ver}
check_libpng ${libwebp_libpng_ver}
ff_check_tiff ${libwebp_tiff_ver} ${2} ${3}

downloadPackage libwebp-${libwebp_v}.tar.gz

cd ${tmp}

if [ -d ${tmp}/${libwebp_srcdir} ] ; then
  rm -rf ${tmp}/${libwebp_srcdir}
fi

cd ${tmp}
tar xvfz ${pkg}/libwebp-${libwebp_v}.tar.gz
cd ${tmp}/${libwebp_srcdir}

if [ ${debug} -gt 0 ] ; then
  echo '>> Unzip complete'
  read k
fi

module purge
module load ffmpeg-dep/${tiff_ffmpeg_ver}
module load libjpeg-turbo/${libwebp_libjpegturbo_ver}
module load giflib/${libwebp_giflib_ver}
module load libpng/${libwebp_libpng_ver}

config="./configure --prefix=${libwebp_prefix} \
            --enable-libwebpmux \
            --enable-libwebpdecoder \
            --enable-libwebpextras \
            --enable-everything \
	    --with-jpegincludedir=${opt}/libjpeg-turbo-${libwebp_libjpegturbo_ver}/include \
            --with-jpeglibdir=${opt}/libjpeg-turbo-${libwebp_libjpegturbo_ver}/lib \
            --with-tiffincludedir=${libwebp_prefix}/include \
            --with-tifflibdir=${libwebp_prefix}/lib \
            --with-gifincludedir=${opt}/giflib-${libwebp_giflib_ver}/include \
            --with-giflibdir=${opt}/giflib-${libwebp_giflib_ver}/lib \
            --with-pngincludedir=${opt}/libpng-${libwebp_libpng_ver}/include \
            --with-pnglibdir=${opt}/libpng-${libwebp_libpng_ver}/lib \
	    --disable-sdl"
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
  echo 'NOTE: WIC (Windows Imaging Component) support is only for Windows builds.'
  echo "      vwebp requires OpenGL support, if you want to build it.  It's basically a GUI webp viewer tool."
  echo '      The SDL build does not appear to support SDL2, and is optional anyways.'
  echo ''
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
rm -rf ${tmp}/${libwebp_srcdir}

}
