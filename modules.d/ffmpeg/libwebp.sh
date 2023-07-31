#!/bin/bash

# Functions for detecting and building libwebp
echo 'Loading libwebp...'

function get_libwebp_library() {
case ${1} in
  1.0.3)
    echo libwebp.so.7.0.5
  ;;
  *)
    echo ''
  ;;
esac
}

#function libwebpInstalled() {
## Cannot evaulate if we dont have modules installed
#if [ ! -f /etc/profile.d/modules.sh ] ; then
#  return 1
#fi
## Load modules if not loaded already
#if [ -z "${MODULEPATH}" ] ; then
#  source /etc/profile.d/modules.sh
#fi 
## If modules is OK, then check libwebp
#if [ ! -f ${MODULEPATH}/libwebp/${1} ] ; then
#  return 1
#else
#  return 0
#fi
#}

function libwebpDepInstalled() {
if [ ! -f "${2}/lib/$(get_libwebp_library ${1})" ] ; then
  return 1
else
  return 0
fi
}

#function check_libwebp() {
#if libwebpInstalled ${1}; then
#  echo "libwebp ${1} is installed."
#else
#  build_libwebp ${1}
#fi
#}

function ff_check_libwebp() {
echo -n "Checking for presence of libwebp-${1} in ${2}..."
if libwebpDepInstalled ${1} ${2}; then
  echo "present"
else
  echo "not present"
  ff_build_libwebp ${1} ${2} ${3}
fi
}

#function build_libwebp() {
#
## Get desired version number to install
#libwebp_v=${1}
#if [ -z "${libwebp_v}" ] ; then
#  libwebp_v=1.0.3
#fi
#
#case ${libwebp_v} in
#  1.0.3) # Sat Jul 13 07:23:45 2019
##   libwebp_libjpeg_ver=9c # Sun Jan 14 11:48 2018
#   libwebp_libjpegturbo_ver=2.0.3 # 2019-09-04 
#   libwebp_tiff_ver=4.1.0 # 2019-Nov-03
#   libwebp_giflib_ver=5.2.1 # 2019-06-24
#  ;;
#  1.2.4) # Sat Aug 06 02:19:15 2022
##   libwebp_libjpeg_ver=9e # Sun Jan 16 10:30 2022
#   libwebp_libjpegturbo_ver=2.0.3 # 2019-09-04
#   libwebp_tiff_ver=4.4.0 # 2022-May-27 14:52
#   libwebp_giflib_ver=5.2.1 # 2019-06-24
#  ;;
#  *)
#   echo "ERROR: Need review for libwebp ${libwebp_v}"
#   exit 4
#   ;;
#esac
#
#echo "Installing libwebp ${libwebp_v}..."
#libwebp_srcdir=libwebp-${libwebp_v}
#
#check_modules
##check_libjpeg ${libwebp_libjpeg_ver}
#check_libjpegturbo ${libwebp_libjpegturbo_ver}
#check_tiff ${libwebp_tiff_ver}
#check_giflib ${libwebp_giflib_ver}
#
#downloadPackage libwebp-${libwebp_v}.tar.gz
#
#cd ${tmp}
#
#if [ -d ${tmp}/${libwebp_srcdir} ] ; then
#  rm -rf ${tmp}/${libwebp_srcdir}
#fi
#
#cd ${tmp}
#tar xvfz ${pkg}/libwebp-${libwebp_v}.tar.gz
#cd ${tmp}/${libwebp_srcdir}
#
#if [ ${debug} -gt 0 ] ; then
#  echo '>> Unzip complete'
#  read k
#fi
#
#module purge
##module load libjpeg/${libwebp_libjpeg_ver}
#module load libjpeg-turbo/${libwebp_libjpegturbo_ver}
#module load tiff/${libwebp_tiff_ver}
#module load giflib/${libwebp_giflib_ver}
#
#config="./configure --prefix=${opt}/libwebp-${libwebp_v} \
#            --enable-libwebpmux \
#            --enable-libwebpdecoder \
#            --enable-libwebpextras \
#            --enable-everything \
#            --with-jpeglibdir=${opt}/libjpeg-turbo-${libwebp_libjpegturbo_ver}/lib \
#            --with-tifflibdir=${opt}/tiff-${libwebp_tiff_ver}/lib \
#            --with-gifincludedir=${opt}/giflib-${libwebp_giflib_ver}/include \
#            --with-giflibdir=${opt}/giflib-${libwebp_giflib_ver}/lib"
#if [ ${debug} -gt 0 ] ; then
#  ./configure --help
#  echo ''
#  module list
#  echo ''
#  echo ${config}
#  read k
#fi
#
#${config}
#
#if [ ${debug} -gt 0 ] ; then
#  echo '>> Configure complete'
#  read k
#fi
#make -j ${ncpu}
#
#if [ ! $? -eq 0 ] ; then
#  exit 4
#fi
#if [ ${debug} -gt 0 ] ; then
#  echo '>> Build complete'
#  read k
#fi
#
#if [ ${run_tests} -gt 0 ] ; then
#  make check
#  echo '>> Tests complete'
#  read k
#fi
#
#make install
#if [ ! $? -eq 0 ] ; then
#  exit 4
#fi
#if [ ${debug} -gt 0 ] ; then
#  echo '>> Install complete'
#  read k
#fi
#
## Create the environment module
#if [ -z "${MODULEPATH}" ] ; then
#  source /etc/profile.d/modules.sh
#fi 
#mkdir -pv ${MODULEPATH}/libwebp
#cat << eof > ${MODULEPATH}/libwebp/${libwebp_v}
##%Module
#
#proc ModulesHelp { } {
#   puts stderr "Puts libwebp-${libwebp_v} into your environment"
#}
#
#set VER ${libwebp_v}
#set PKG ${opt}/libwebp-\$VER
#
#module-whatis   "Loads libwebp-${libwebp_v}"
#conflict libwebp
#module load libjpeg-turbo/${libwebp_libjpegturbo_ver}
#module load tiff/${libwebp_tiff_ver}
#module load giflib/${libwebp_giflib_ver}
#prereq libjpeg-turbo/${libwebp_libjpegturbo_ver}
#prereq tiff/${libwebp_tiff_ver}
#prereq giflib/${libwebp_giflib_ver}
#
#prepend-path CPATH \$PKG/include
#prepend-path C_INCLUDE_PATH \$PKG/include
#prepend-path CPLUS_INCLUDE_PATH \$PKG/include
#prepend-path LD_LIBRARY_PATH \$PKG/lib
#prepend-path PKG_CONFIG_PATH \$PKG/lib/pkgconfig
#prepend-path PATH \$PKG/bin
#prepend-path MANPATH \$PKG/share/man
#
#eof
#
#cd ${root}
#rm -rf ${tmp}/${libwebp_srcdir}
#
#}

function ff_build_libwebp() {

# Get desired version number to install
libwebp_v=${1}
if [ -z "${libwebp_v}" ] ; then
  libwebp_v=1.0.3
fi

#case ${libwebp_v} in
#  1.0.3) # Sat Jul 13 07:23:45 2019
#   libwebp_tiff_ver=4.1.0 # 2019-Nov-03
#   libwebp_giflib_ver=5.2.1 # 2019-06-24
#  ;;
#  1.2.4) # Sat Aug 06 02:19:15 2022
#   libwebp_tiff_ver=4.4.0 # 2022-May-27 14:52
#   libwebp_giflib_ver=5.2.1 # 2019-06-24
#  ;;
#  *)
#   echo "ERROR: Need review for libwebp ${libwebp_v}"
#   exit 4
#   ;;
#esac

libwebp_ffmpeg_ver=${3}

libwebp_libjpegturbo_ver=${ffmpeg_libjpegturbo_ver}
libwebp_tiff_ver=${ffmpeg_tiff_ver}
libwebp_giflib_ver=${ffmpeg_giflib_ver}
libwebp_libpng_ver=${ffmpeg_libpng_ver}
#libwebp_sdl_ver=${ffmpeg_sdl_ver}

libwebp_srcdir=libwebp-${libwebp_v}
libwebp_prefix=${2}

echo "Installing libwebp-${libwebp_v} in ${libwebp_prefix}..."

check_modules
check_libjpegturbo ${libwebp_libjpegturbo_ver}
check_giflib ${libwebp_giflib_ver}
check_libpng ${libwebp_libpng_ver}
ff_check_tiff ${libwebp_tiff_ver} ${2} ${3}
#ff_check_sdl ${libwebp_sdl_ver} ${2} ${3}

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
