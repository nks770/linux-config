#!/bin/bash

# Functions for detecting and building Speex
# The Speex codec has been obsoleted by Opus. It will continue to be available, but since Opus is better than Speex in all aspects, users are encouraged to switch
echo 'Loading speex...'

function get_speex_library() {
case ${1} in
  1.2.0)
    echo libspeex.so.1.5.1
  ;;
  *)
    echo ''
  ;;
esac
}

function speexDepInstalled() {
if [ ! -f "${2}/lib/$(get_speex_library ${1})" ] ; then
  return 1
else
  return 0
fi
}

function ff_check_speex() {
echo -n "Checking for presence of speex-${1} in ${2}..."
if speexDepInstalled ${1} ${2}; then
  echo "present"
else
  echo "not present"
  ff_build_speex ${1} ${2} ${3}
fi
}


function ff_build_speex() {

# Get desired version number to install
speex_v=${1}
if [ -z "${speex_v}" ] ; then
  speex_v=1.2.0
fi

#case ${speex_v} in
#  1.2.0) # December 7, 2016
#   speex_libogg_ver=1.3.5
#  ;;
#  *)
#   echo "ERROR: Review needed for speex ${speex_v}"
#   exit 4 # Please review
#  ;;
#esac

speex_ffmpeg_ver=${3}
speex_libogg_ver=${ffmpeg_libogg_ver}

speex_srcdir=speex-${speex_v}
speex_prefix=${2}

echo "Installing ${speex_srcdir} in ${speex_prefix}..."

check_modules
ff_check_libogg ${speex_libogg_ver} ${2} ${3}

downloadPackage ${speex_srcdir}.tar.gz

cd ${tmp}

if [ -d ${tmp}/${speex_srcdir} ] ; then
  rm -rf ${tmp}/${speex_srcdir}
fi

cd ${tmp}
tar xvfz ${pkg}/${speex_srcdir}.tar.gz
cd ${tmp}/${speex_srcdir}

if [ ${debug} -gt 0 ] ; then
  echo '>> Unzip complete'
  read k
fi

module purge
module load ffmpeg-dep/${speex_ffmpeg_ver}

config="./configure --prefix=${speex_prefix}"

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
rm -rf ${tmp}/${speex_srcdir}

}
