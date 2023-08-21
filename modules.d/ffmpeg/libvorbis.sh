#!/bin/bash

# Functions for detecting and building libvorbis
echo 'Loading libvorbis...'

function get_libvorbis_library() {
case ${1} in
  1.3.6)
    echo libvorbis.so.0.4.8
  ;;
  *)
    echo ''
  ;;
esac
}

function libvorbisDepInstalled() {
if [ ! -f "${2}/lib/$(get_libvorbis_library ${1})" ] ; then
  return 1
else
  return 0
fi
}

function ff_check_libvorbis() {
echo -n "Checking for presence of libvorbis-${1} in ${2}..."
if libvorbisDepInstalled ${1} ${2}; then
  echo "present"
else
  echo "not present"
  ff_build_libvorbis ${1} ${2} ${3}
fi
}


function ff_build_libvorbis() {

# Get desired version number to install
libvorbis_v=${1}
if [ -z "${libvorbis_v}" ] ; then
  libvorbis_v=1.3.7
fi

case ${libvorbis_v} in
  1.3.6)              # 2018-03-16
#   libogg_ver=1.3.3   # 2017-11-07
   libvorbis_doxygen_ver=1.8.14 # 2017-12-25
  ;;
  1.3.7)              # 2020-07-04
#   libogg_ver=1.3.4   # 2019-08-30
   libvorbis_doxygen_ver=1.8.18 # 2020-04-12
  ;;
  *)
   echo "ERROR: Review needed for libvorbis ${libvorbis_v}"
   exit 4 # Please review
  ;;
esac

## Optimized dependency strategy
#if [ "${dependency_strategy}" == "optimized" ] ; then
#  libogg_ver=${global_libogg}
#fi

libvorbis_ffmpeg_ver=${3}
libvorbis_libogg_ver=${ffmpeg_libogg_ver}

libvorbis_srcdir=libvorbis-${libvorbis_v}
libvorbis_prefix=${2}

echo "Installing ${libvorbis_srcdir} in ${libvorbis_prefix}..."

check_modules
ff_check_libogg ${libvorbis_libogg_ver} ${2} ${3}
check_doxygen ${libvorbis_doxygen_ver}

downloadPackage ${libvorbis_srcdir}.tar.gz

cd ${tmp}

if [ -d ${tmp}/${libvorbis_srcdir} ] ; then
  rm -rf ${tmp}/${libvorbis_srcdir}
fi

cd ${tmp}
tar xvfz ${pkg}/${libvorbis_srcdir}.tar.gz
cd ${tmp}/${libvorbis_srcdir}

if [ ${debug} -gt 0 ] ; then
  echo '>> Unzip complete'
  read k
fi

module purge
module load ffmpeg-dep/${libvorbis_ffmpeg_ver}
module load doxygen/${libvorbis_doxygen_ver}

config="./configure --prefix=${libvorbis_prefix} --enable-docs"

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
rm -rf ${tmp}/${libvorbis_srcdir}

}
