#!/bin/bash

# Functions for detecting and building FLAC
echo 'Loading flac...'

function get_flac_library() {
case ${1} in
  1.3.3)
    echo libFLAC.so.8.3.0
  ;;
  *)
    echo ''
  ;;
esac
}

function flacDepInstalled() {
if [ ! -f "${2}/lib/$(get_flac_library ${1})" ] ; then
  return 1
else
  return 0
fi
}

function ff_check_flac() {
echo -n "Checking for presence of flac-${1} in ${2}..."
if flacDepInstalled ${1} ${2}; then
  echo "present"
else
  echo "not present"
  ff_build_flac ${1} ${2} ${3}
fi
}


function ff_build_flac() {

# Get desired version number to install
flac_v=${1}
if [ -z "${flac_v}" ] ; then
  echo "ERROR: No flac version specified!"
  exit 2
fi

case ${flac_v} in
  1.3.3) # 4 Aug 2019
   flac_nasm_ver=2.14.02
#   libogg_ver=1.3.4
  ;;
  *)
   echo "ERROR: Review needed for flac ${flac_v}"
   exit 4 # Please review
  ;;
esac

## Optimized dependency strategy
#if [ "${dependency_strategy}" == "optimized" ] ; then
#  libogg_ver=${global_libogg}
#fi

flac_ffmpeg_ver=${3}
flac_libogg_ver=${ffmpeg_libogg_ver}

flac_srcdir=flac-${flac_v}
flac_prefix=${2}

echo "Installing ${flac_srcdir} in ${flac_prefix}..."

check_modules
check_nasm ${flac_nasm_ver}
ff_check_libogg ${flac_libogg_ver} ${2} ${3}

downloadPackage ${flac_srcdir}.tar.xz

cd ${tmp}

if [ -d ${tmp}/${flac_srcdir} ] ; then
  rm -rf ${tmp}/${flac_srcdir}
fi

cd ${tmp}
tar xvfJ ${pkg}/${flac_srcdir}.tar.xz
cd ${tmp}/${flac_srcdir}

if [ ${debug} -gt 0 ] ; then
  echo '>> Unzip complete'
  read k
fi

module purge
module load ffmpeg-dep/${flac_ffmpeg_ver}
module load nasm/${flac_nasm_ver}

config="./configure --prefix=${flac_prefix} \
            --with-ogg=${flac_prefix} \
            --disable-xmms-plugin"

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
rm -rf ${tmp}/${flac_srcdir}

}
