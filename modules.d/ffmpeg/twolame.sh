#!/bin/bash

# Functions for detecting and building TwoLAME
echo 'Loading twolame...'

function get_twolame_library() {
case ${1} in
  0.4.0)
    echo libtwolame.so.0.0.0
  ;;
  *)
    echo ''
  ;;
esac
}

function twolameDepInstalled() {
if [ ! -f "${2}/lib/$(get_twolame_library ${1})" ] ; then
  return 1
else
  return 0
fi
}

function ff_check_twolame() {
echo -n "Checking for presence of twolame-${1} in ${2}..."
if twolameDepInstalled ${1} ${2}; then
  echo "present"
else
  echo "not present"
  ff_build_twolame ${1} ${2} ${3}
fi
}


function ff_build_twolame() {

# Get desired version number to install
twolame_v=${1}
if [ -z "${twolame_v}" ] ; then
  twolame_v=0.4.0
fi

#case ${twolame_v} in
#  0.4.0) # 2019-10-11
#   twolame_libsndfile_ver=1.0.28-flac1.3.3 # 2017-04-02 / 2019-08-04
#  ;;
#  *)
#   echo "ERROR: Review needed for twolame ${twolame_v}"
#   exit 4 # Please review
#  ;;
#esac

twolame_ffmpeg_ver=${3}
twolame_libsndfile_ver=${ffmpeg_libsndfile_ver}

twolame_srcdir=twolame-${twolame_v}
twolame_prefix=${2}

echo "Installing ${twolame_srcdir} in ${twolame_prefix}..."

check_modules
ff_check_libsndfile ${twolame_libsndfile_ver} ${2} ${3}

downloadPackage ${twolame_srcdir}.tar.gz

cd ${tmp}

if [ -d ${tmp}/${twolame_srcdir} ] ; then
  rm -rf ${tmp}/${twolame_srcdir}
fi

cd ${tmp}
tar xvfz ${pkg}/${twolame_srcdir}.tar.gz
cd ${tmp}/${twolame_srcdir}

if [ ${debug} -gt 0 ] ; then
  echo '>> Unzip complete'
  read k
fi

module purge
module load ffmpeg-dep/${twolame_ffmpeg_ver}

config="./configure --prefix=${twolame_prefix}"

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
rm -rf ${tmp}/${twolame_srcdir}

}
