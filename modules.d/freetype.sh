#!/bin/bash

# Functions for detecting and building freetype
echo 'Loading freetype...'

function get_freetype_library() {
case ${1} in
  1.0.3)
    echo unknown.so
  ;;
  *)
    echo ''
  ;;
esac
}

function freetypeDepInstalled() {
if [ ! -f "${2}/lib/$(get_freetype_library ${1})" ] ; then
  return 1
else
  return 0
fi
}

function ff_check_freetype() {
echo -n "Checking for presence of freetype-${1} in ${2}..."
if freetypeDepInstalled ${1} ${2}; then
  echo "present"
else
  echo "not present"
  ff_build_freetype ${1} ${2} ${3}
fi
}

function ff_build_freetype() {

# Get desired version number to install
freetype_v=${1}
if [ -z "${freetype_v}" ] ; then
  freetype_v=2.12.1
fi

freetype_ffmpeg_ver=${3}

freetype_bzip2_ver=${ffmpeg_bzip2_ver}

freetype_srcdir=freetype-${freetype_v}
freetype_prefix=${2}

echo "Installing freetype-${freetype_v} in ${freetype_prefix}..."

check_modules
check_bzip2 ${freetype_bzip2_ver}

downloadPackage freetype-${freetype_v}.tar.gz

cd ${tmp}

if [ -d ${tmp}/${freetype_srcdir} ] ; then
  rm -rf ${tmp}/${freetype_srcdir}
fi

cd ${tmp}
tar xvfz ${pkg}/freetype-${freetype_v}.tar.gz
cd ${tmp}/${freetype_srcdir}

if [ ${debug} -gt 0 ] ; then
  echo '>> Unzip complete'
  read k
fi

module purge
module load bzip2/${freetype_bzip2_ver}

config="./configure --prefix=${freetype_prefix} CFLAGS=-I${opt}/bzip2-${freetype_bzip2_ver}/include LDFLAGS=-L${opt}/bzip2-${freetype_bzip2_ver}/lib"
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
rm -rf ${tmp}/${freetype_srcdir}
}
