#!/bin/bash

# Functions for detecting and building libsndfile
echo 'Loading libsndfile...'

function get_libsndfile_library() {
case ${1} in
  1.0.28)
    echo libsndfile.so.1.0.28
  ;;
  1.0.31)
    echo libsndfile.so.1.0.31
  ;;
  *)
    echo ''
  ;;
esac
}

function libsndfileDepInstalled() {
if [ ! -f "${2}/lib/$(get_libsndfile_library ${1})" ] ; then
  return 1
else
  return 0
fi
}

function ff_check_libsndfile() {
echo -n "Checking for presence of libsndfile-${1} in ${2}..."
if libsndfileDepInstalled ${1} ${2}; then
  echo "present"
else
  echo "not present"
  ff_build_libsndfile ${1} ${2} ${3}
fi
}


function ff_build_libsndfile() {

# Get desired version number to install
libsndfile_v=${1}
if [ -z "${libsndfile_v}" ] ; then
  echo "ERROR: No libsndfile version specified!"
  exit 2
fi

case ${libsndfile_v} in
  1.0.28) # 2017-04-02
   libsndfile_ext=tar.gz
   libsndfile_args=xvfz
  ;;
  1.0.31) # 2021-01-24
   libsndfile_ext=tar.bz2
   libsndfile_args=xvfj
  ;;
  *)
   echo "ERROR: Review needed for libsndfile ${libsndfile_v}"
   exit 4 # Please review
  ;;
esac

## Optimized dependency strategy
#if [ "${dependency_strategy}" == "optimized" ] ; then
#  libogg_ver=${global_libogg}
#fi

libsndfile_ffmpeg_ver=${3}
libsndfile_libogg_ver=${ffmpeg_libogg_ver}
libsndfile_libvorbis_ver=${ffmpeg_libvorbis_ver}
libsndfile_flac_ver=${ffmpeg_flac_ver}
libsndfile_opus_ver=${ffmpeg_opus_ver}

libsndfile_srcdir=libsndfile-${libsndfile_v}
libsndfile_prefix=${2}

echo "Installing ${libsndfile_srcdir} in ${libsndfile_prefix}..."

check_modules
ff_check_libogg ${libsndfile_libogg_ver} ${2} ${3}
ff_check_libvorbis ${libsndfile_libvorbis_ver} ${2} ${3}
ff_check_flac ${libsndfile_flac_ver} ${2} ${3}
ff_check_opus ${libsndfile_opus_ver} ${2} ${3}

downloadPackage ${libsndfile_srcdir}.${libsndfile_ext}

cd ${tmp}

if [ -d ${tmp}/${libsndfile_srcdir} ] ; then
  rm -rf ${tmp}/${libsndfile_srcdir}
fi

cd ${tmp}
tar ${libsndfile_args} ${pkg}/${libsndfile_srcdir}.${libsndfile_ext}
cd ${tmp}/${libsndfile_srcdir}

if [ ${debug} -gt 0 ] ; then
  echo '>> Unzip complete'
  read k
fi

module purge
module load ffmpeg-dep/${libsndfile_ffmpeg_ver}

config="./configure --prefix=${libsndfile_prefix}"

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
rm -rf ${tmp}/${libsndfile_srcdir}

}
