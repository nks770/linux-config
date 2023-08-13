#!/bin/bash

# Functions for detecting and building freetype
echo 'Loading harfbuzz...'

function get_harfbuzz_library() {
case ${1} in
  2.6.4)
    echo xlibfontconfig.so.1.12.0
  ;;
  *)
    echo ''
  ;;
esac
}

function harfbuzzDepInstalled() {
if [ ! -f "${2}/lib/$(get_fontconfig_library ${1})" ] ; then
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

harfbuzz_ffmpeg_ver=${3}
harfbuzz_icu_ver=${ffmpeg_icu_ver}
harfbuzz_graphite2_ver=${ffmpeg_graphite2_ver}

harfbuzz_srcdir=harfbuzz-${harfbuzz_v}
harfbuzz_prefix=${2}

echo "Installing harfbuzz-${harfbuzz_v} in ${harfbuzz_prefix}..."

check_modules
check_icu ${harfbuzz_icu_ver}
check_graphite2 ${harfbuzz_graphite2_ver}

downloadPackage harfbuzz-${harfbuzz_v}.tar.bz2

cd ${tmp}

if [ -d ${tmp}/${harfbuzz_srcdir} ] ; then
  rm -rf ${tmp}/${harfbuzz_srcdir}
fi

cd ${tmp}
tar xvfj ${pkg}/harfbuzz-${harfbuzz_v}.tar.bz2
cd ${tmp}/${harfbuzz_srcdir}

module purge
module load icu/${harfbuzz_icu_ver}
module load graphite2/${harfbuzz_graphite2_ver}

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
