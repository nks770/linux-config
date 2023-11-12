#!/bin/bash

# Functions for detecting and building libbs2b
echo 'Loading libbs2b...'

function get_libbs2b_library() {
case ${1} in
  3.1.0)
    echo libbs2b.so.0.0.0
  ;;
  *)
    echo ''
  ;;
esac
}

function libbs2bDepInstalled() {
if [ ! -f "${2}/lib/$(get_libbs2b_library ${1})" ] ; then
  return 1
else
  return 0
fi
}

function ff_check_libbs2b() {
echo -n "Checking for presence of libbs2b-${1} in ${2}..."
if libbs2bDepInstalled ${1} ${2}; then
  echo "present"
else
  echo "not present"
  ff_build_libbs2b ${1} ${2} ${3}
fi
}


function ff_build_libbs2b() {

# Get desired version number to install
libbs2b_v=${1}
if [ -z "${libbs2b_v}" ] ; then
  libbs2b_v=3.1.0
fi

#case ${libbs2b_v} in
#  3.1.0-flac1.3.3) # 2009-06-04 / 2019-08-04
#   libbs2b_vv=3.1.0
#   libsndfile_ver=1.0.28-flac1.3.3 # 2017-04-02 / 2019-08-04
#  ;;
#  *)
#   echo "ERROR: Review needed for libbs2b ${libbs2b_v}"
#   exit 4 # Please review
#  ;;
#esac

libbs2b_ffmpeg_ver=${3}
libbs2b_libsndfile_ver=${ffmpeg_libsndfile_ver}

libbs2b_srcdir=libbs2b-${libbs2b_v}
libbs2b_prefix=${2}

echo "Installing ${libbs2b_srcdir} in ${libbs2b_prefix}..."

check_modules
ff_check_libsndfile ${libbs2b_libsndfile_ver} ${2} ${3}

downloadPackage ${libbs2b_srcdir}.tar.gz

cd ${tmp}

if [ -d ${tmp}/${libbs2b_srcdir} ] ; then
  rm -rf ${tmp}/${libbs2b_srcdir}
fi

cd ${tmp}
tar xvfz ${pkg}/${libbs2b_srcdir}.tar.gz
cd ${tmp}/${libbs2b_srcdir}

if [ ${debug} -gt 0 ] ; then
  echo '>> Unzip complete'
  read k
fi

module purge
module load ffmpeg-dep/${libbs2b_ffmpeg_ver}

config="./configure --prefix=${libbs2b_prefix}"

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
rm -rf ${tmp}/${libbs2b_srcdir}

}
