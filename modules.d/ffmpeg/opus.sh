#!/bin/bash

# Functions for detecting and building libopus
echo 'Loading opus...'

function get_opus_library() {
case ${1} in
  1.3.1)
    echo libopus.so.0.8.0
  ;;
  *)
    echo ''
  ;;
esac
}

function opusDepInstalled() {
if [ ! -f "${2}/lib/$(get_opus_library ${1})" ] ; then
  return 1
else
  return 0
fi
}

function ff_check_opus() {
echo -n "Checking for presence of opus-${1} in ${2}..."
if opusDepInstalled ${1} ${2}; then
  echo "present"
else
  echo "not present"
  ff_build_opus ${1} ${2} ${3}
fi
}


function ff_build_opus() {

# Get desired version number to install
opus_v=${1}
if [ -z "${opus_v}" ] ; then
  opus_v=1.3.1
fi

case ${opus_v} in
  1.3.1) # Apr 12, 2019
   opus_doxygen_ver=1.8.15 # 2018-12-27
  ;;
  *)
   echo "ERROR: Review needed for opus ${opus_v}"
   exit 4 # Please review
  ;;
esac

opus_ffmpeg_ver=${3}

opus_srcdir=opus-${opus_v}
opus_prefix=${2}

echo "Installing ${opus_srcdir} in ${opus_prefix}..."

check_modules
check_doxygen ${opus_doxygen_ver}

downloadPackage opus-${opus_v}.tar.gz

cd ${tmp}

if [ -d ${tmp}/${opus_srcdir} ] ; then
  rm -rf ${tmp}/${opus_srcdir}
fi

cd ${tmp}
tar xvfz ${pkg}/${opus_srcdir}.tar.gz
cd ${tmp}/${opus_srcdir}

if [ ${debug} -gt 0 ] ; then
  echo '>> Unzip complete'
  read k
fi

module purge
module load doxygen/${opus_doxygen_ver}

# NOTE
# The 'No inline ASM for your platform' message is normal for x86 hosts. It's a bit
# misleading since we added intrinsic optimization. You should be ok on that count 
# as long as you have something like
#
#    Intrinsics Optimizations.......: x86 SSE SSE2 SSE4.1 AVX
#    Run-time CPU detection: ........ x86 AVX
#
# a few lines down.

config="./configure --prefix=${opus_prefix}"

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
  echo '# NOTE'
  echo "# The 'No inline ASM for your platform' message is normal for x86 hosts. It's a bit"
  echo "# misleading since we added intrinsic optimization. You should be ok on that count"
  echo '# as long as you have something like'
  echo '#'
  echo '#    Intrinsics Optimizations.......: x86 SSE SSE2 SSE4.1 AVX'
  echo '#    Run-time CPU detection: ........ x86 AVX'
  echo '#'
  echo '# a few lines down.'
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
rm -rf ${tmp}/${opus_srcdir}

}
