#!/bin/bash

# Functions for detecting and building harfbuzz
echo 'Loading harfbuzz...'

function get_harfbuzz_library() {
case ${1} in
  2.6.4)
    echo libharfbuzz.so.0.20600.4
  ;;
  2.6.5)
    echo libharfbuzz.so.0.20600.5
  ;;
  *)
    echo ''
  ;;
esac
}

function harfbuzzDepInstalled() {
if [ ! -f "${2}/lib/$(get_harfbuzz_library ${1})" ] ; then
  return 1
else
  return 0
fi
}

function ff_check_harfbuzz() {
echo -n "Checking for presence of harfbuzz-${1} in ${2}..."
if harfbuzzDepInstalled ${1} ${2}; then
  echo "present"
else
  echo "not present"
  ff_build_harfbuzz ${1} ${2} ${3}
fi
}


function ff_build_harfbuzz() {

# Get desired version number to install
harfbuzz_v=${1}
if [ -z "${harfbuzz_v}" ] ; then
  harfbuzz_v=2.6.4
fi

case ${harfbuzz_v} in
  2.6.4) # 2018-12-20
   harfbuzz_package=harfbuzz-${harfbuzz_v}.tar.xz
   harfbuzz_tar=xvfJ
  ;;
  2.6.5) # 2020-04-17
   harfbuzz_package=harfbuzz-${harfbuzz_v}.tar.xz
   harfbuzz_tar=xvfJ
  ;;
  *)
   echo "ERROR: Review needed for harfbuzz ${harfbuzz_v}"
   exit 4 # Please review
  ;;
esac

harfbuzz_ffmpeg_ver=${3}
harfbuzz_icu_ver=${ffmpeg_icu_ver}
harfbuzz_graphite2_ver=${ffmpeg_graphite2_ver}

harfbuzz_srcdir=harfbuzz-${harfbuzz_v}
harfbuzz_prefix=${2}

echo "Installing harfbuzz-${harfbuzz_v} in ${harfbuzz_prefix}..."

check_modules
check_icu ${harfbuzz_icu_ver}
ff_check_graphite2 ${harfbuzz_graphite2_ver} ${2} ${3}

downloadPackage ${harfbuzz_package}

cd ${tmp}

if [ -d ${tmp}/${harfbuzz_srcdir} ] ; then
  rm -rf ${tmp}/${harfbuzz_srcdir}
fi

cd ${tmp}
tar ${harfbuzz_tar} ${pkg}/${harfbuzz_package}
cd ${tmp}/${harfbuzz_srcdir}

if [ ${debug} -gt 0 ] ; then
  echo '>> Unzip complete'
  read k
fi

module purge
module load ffmpeg-dep/${harfbuzz_ffmpeg_ver}
module load icu/${harfbuzz_icu_ver}

config="./configure --with-graphite2 --prefix=${harfbuzz_prefix} PKG_CONFIG_PATH=${PKG_CONFIG_PATH}:${harfbuzz_prefix}/lib/pkgconfig"

if [ ${debug} -gt 0 ] ; then
  ./configure --help
  echo ''
  module list
  echo PKG_CONFIG_PATH=${PKG_CONFIG_PATH}
  echo ''
  echo ${config}
  read k
fi

${config}

if [ ${debug} -gt 0 ] ; then
  echo PKG_CONFIG_PATH=${PKG_CONFIG_PATH}
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
rm -rf ${tmp}/${harfbuzz_srcdir}
}
