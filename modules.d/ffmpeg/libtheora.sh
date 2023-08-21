#!/bin/bash

# Functions for detecting and building libtheora
echo 'Loading libtheora...'

function get_libtheora_library() {
case ${1} in
  1.1.1)
    echo libtheora.so.0.3.10
  ;;
  *)
    echo ''
  ;;
esac
}

function libtheoraDepInstalled() {
if [ ! -f "${2}/lib/$(get_libtheora_library ${1})" ] ; then
  return 1
else
  return 0
fi
}

function ff_check_libtheora() {
echo -n "Checking for presence of libtheora-${1} in ${2}..."
if libtheoraDepInstalled ${1} ${2}; then
  echo "present"
else
  echo "not present"
  ff_build_libtheora ${1} ${2} ${3}
fi
}


function ff_build_libtheora() {

# Get desired version number to install
libtheora_v=${1}
if [ -z "${libtheora_v}" ] ; then
  libtheora_v=1.1.1
fi

case ${libtheora_v} in
  1.1.1) # 2009 October 1
#   libogg_ver=1.3.4
#   libvorbis_ver=1.3.7
   libtheora_doxygen_ver=1.6.1  # 2009-08-25
   libtheora_doxygen_ver=1.8.14 # 2017-12-25
  ;;
  *)
   echo "ERROR: Review needed for libtheora ${libtheora_v}"
   exit 4 # Please review
  ;;
esac

## Optimized dependency strategy
#if [ "${dependency_strategy}" == "optimized" ] ; then
#  libogg_ver=${global_libogg}
#fi

libtheora_ffmpeg_ver=${3}
libtheora_libogg_ver=${ffmpeg_libogg_ver}
libtheora_libvorbis_ver=${ffmpeg_libvorbis_ver}

libtheora_srcdir=libtheora-${libtheora_v}
libtheora_prefix=${2}

echo "Installing ${libtheora_srcdir} in ${libtheora_prefix}..."

check_modules
ff_check_libogg ${libtheora_libogg_ver} ${2} ${3}
ff_check_libvorbis ${libtheora_libvorbis_ver} ${2} ${3}
check_doxygen ${libtheora_doxygen_ver}

downloadPackage ${libtheora_srcdir}.tar.bz2

cd ${tmp}

if [ -d ${tmp}/${libtheora_srcdir} ] ; then
  rm -rf ${tmp}/${libtheora_srcdir}
fi

cd ${tmp}
tar xvfj ${pkg}/${libtheora_srcdir}.tar.bz2
cd ${tmp}/${libtheora_srcdir}

if [ ${debug} -gt 0 ] ; then
  echo '>> Unzip complete'
  read k
fi

## Patch needed because png_sizeof() function removed in libpng 1.6+
## Please use sizeof() insgtead of png_sizeof()
#if [ "${libtheora_v}" == "1.1.1" ] ; then
#cat << eof > png2theora.patch
#Index: examples/png2theora.c
#===================================================================
#--- examples/png2theora.c       2009-08-22 18:14:04.000000000 +0000
#+++ examples/png2theora.c       2021-04-25 04:47:25.666263747 +0000
#@@ -462,9 +462,9 @@
#   png_set_strip_alpha(png_ptr);
#
#   row_data = (png_bytep)png_malloc(png_ptr,
#-    3*height*width*png_sizeof(*row_data));
#+    3*height*width*sizeof(*row_data));
#   row_pointers = (png_bytep *)png_malloc(png_ptr,
#-    height*png_sizeof(*row_pointers));
#+    height*sizeof(*row_pointers));
#   for(y = 0; y < height; y++) {
#     row_pointers[y] = row_data + y*(3*width);
#   }
#eof
#patch -N -Z -b -p0 < png2theora.patch
#if [ ! $? -eq 0 ] ; then
#  exit 4
#fi
#fi
#
#if [ ${debug} -gt 0 ] ; then
#  echo '>> Patching complete'
#  read k
#fi

module purge
module load ffmpeg-dep/${libtheora_ffmpeg_ver}
module load doxygen/${libtheora_doxygen_ver}

config="./configure --prefix=${libtheora_prefix} --disable-examples"

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
rm -rf ${tmp}/${libtheora_srcdir}

}
