#!/bin/bash

# Functions for detecting and building libass
echo 'Loading libass...'

function get_libass_library() {
case ${1} in
  0.14.0)
    echo libass.so.9.0.2
  ;;
  *)
    echo ''
  ;;
esac
}

function libassDepInstalled() {
if [ ! -f "${2}/lib/$(get_libass_library ${1})" ] ; then
  return 1
else
  return 0
fi
}

function ff_check_libass() {
echo -n "Checking for presence of libass-${1} in ${2}..."
if libassDepInstalled ${1} ${2}; then
  echo "present"
else
  echo "not present"
  ff_build_libass ${1} ${2} ${3}
fi
}


function ff_build_libass() {

# Get desired version number to install
libass_v=${1}
if [ -z "${libass_v}" ] ; then
  libass_v=0.14.0
fi

case ${libass_v} in
  0.14.0) # 2017-10-31
   libass_nasm_ver=2.13.01      # 2017-05-01
  ;;
#  0.16.0) # 2022-05-12
#   nasm_ver=2.15.05     # 2020-08-28
#  ;;
  *)
   echo "ERROR: Need review for libass ${libass_v}"
   exit 4
   ;;
esac

libass_ffmpeg_ver=${3}
libass_fribidi_ver=${ffmpeg_fribidi_ver}

libass_srcdir=libass-${libass_v}
libass_prefix=${2}

echo "Installing libass-${libass_v} in ${libass_prefix}..."

check_modules
check_nasm ${libass_nasm_ver}
check_fribidi ${libass_fribidi_ver}
ff_check_freetype ${ffmpeg_freetype_ver} ${2} ${3}
ff_check_fontconfig ${ffmpeg_fontconfig_ver} ${2} ${3}

downloadPackage ${libass_srcdir}.tar.gz

cd ${tmp}

if [ -d ${tmp}/${libass_srcdir} ] ; then
  rm -rf ${tmp}/${libass_srcdir}
fi

cd ${tmp}
tar xvfz ${pkg}/${libass_srcdir}.tar.gz
cd ${tmp}/${libass_srcdir}

if [ ${debug} -gt 0 ] ; then
  echo '>> Unzip complete'
  read k
fi

module purge
module load ffmpeg-dep/${libass_ffmpeg_ver}
module load nasm/${libass_nasm_ver}
module load fribidi/${libass_fribidi_ver}

config="./configure --prefix=${libass_prefix}"
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
rm -rf ${tmp}/${libass_srcdir}

}
