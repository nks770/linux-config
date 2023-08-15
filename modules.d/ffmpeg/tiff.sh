#!/bin/bash

# Functions for detecting and building tiff
echo 'Loading tiff...'

function get_tiff_library() {
case ${1} in
  4.1.0)
    echo libtiff.so.5.5.0
  ;;
  *)
    echo ''
  ;;
esac
}

function tiffDepInstalled() {
if [ ! -f "${2}/lib/$(get_tiff_library ${1})" ] ; then
  return 1
else
  return 0
fi
}

function ff_check_tiff() {
echo -n "Checking for presence of tiff-${1} in ${2}..."
if tiffDepInstalled ${1} ${2}; then
  echo "present"
else
  echo "not present"
  ff_build_tiff ${1} ${2} ${3}
  ff_build_libwebp ${ffmpeg_libwebp_ver} ${2} ${3}
  ff_build_tiff ${1} ${2} ${3}
fi
}

function ff_build_tiff() {

tiff_use_cmake=1

# Get desired version number to install
tiff_v=${1}
if [ -z "${tiff_v}" ] ; then
  tiff_v=4.1.0
fi

case ${tiff_v} in
  4.0.9) # 2017-Nov-18
   tiff_cmake_ver=3.9.6 # 2017-11-10
  ;;
  4.1.0) # 2019-Nov-03
   tiff_cmake_ver=3.15.5 # 2019-10-30
  ;;
  4.4.0) # 2022-May-27 14:53
   tiff_cmake_ver=3.21.6 # 2022-03-04
  ;;
  *)
   echo "ERROR: Review needed for tiff ${tiff_v}"
   exit 4 # Please review
  ;;
esac

tiff_ffmpeg_ver=${3}

tiff_zlib_ver=${global_zlib}
tiff_xz_ver=${global_xz}
tiff_jbigkit_ver=${ffmpeg_jbigkit_ver}
tiff_libjpegturbo_ver=${ffmpeg_libjpegturbo_ver}
tiff_zstd_ver=${ffmpeg_zstd_ver}
tiff_libwebp_ver=${ffmpeg_libwebp_ver}

tiff_zlib_lib=$(get_zlib_library ${tiff_zlib_ver})
tiff_xz_lib=$(get_xz_library ${tiff_xz_ver})
tiff_jbigkit_lib=$(get_jbigkit_library ${tiff_jbigkit_ver})
tiff_libjpegturbo_lib=$(get_libjpegturbo_library ${tiff_libjpegturbo_ver})
tiff_zstd_lib=$(get_zstd_library ${tiff_zstd_ver})
tiff_libwebp_lib=$(get_libwebp_library ${tiff_libwebp_ver})

tiff_srcdir=tiff-${tiff_v}
tiff_prefix=${2}
echo "Installing tiff-${tiff_v} in ${tiff_prefix}..."

check_modules
if [ ${tiff_use_cmake} -gt 0 ] ; then
  check_cmake ${tiff_cmake_ver}
fi
check_libjpegturbo ${tiff_libjpegturbo_ver}
check_zlib ${tiff_zlib_ver}
check_xz ${tiff_xz_ver}
check_jbigkit ${tiff_jbigkit_ver}
check_zstd ${tiff_zstd_ver}

downloadPackage tiff-${tiff_v}.tar.gz

cd ${tmp}

if [ -d ${tmp}/${tiff_srcdir} ] ; then
  rm -rf ${tmp}/${tiff_srcdir}
fi

cd ${tmp}
tar xvfz ${pkg}/tiff-${tiff_v}.tar.gz
cd ${tmp}/${tiff_srcdir}

if [ ${debug} -gt 0 ] ; then
  echo '>> Unzip complete'
  read k
fi

module purge
module load ffmpeg-dep/${tiff_ffmpeg_ver}
if [ ${tiff_use_cmake} -gt 0 ] ; then
  module load cmake/${tiff_cmake_ver}
fi
module load libjpeg-turbo/${tiff_libjpegturbo_ver}
module load zlib/${tiff_zlib_ver}
module load xz/${tiff_xz_ver}
module load jbigkit/${tiff_jbigkit_ver}
module load zstd/${tiff_zstd_ver}

if [ ${tiff_use_cmake} -gt 0 ] ; then

if [ ! -d ${tmp}/${tiff_srcdir}/build ] ; then
  mkdir -v ${tmp}/${tiff_srcdir}/build
fi
cd ${tmp}/${tiff_srcdir}/build

# Only include libwebp if it exists
if [ -f "${tiff_prefix}/lib/${tiff_libwebp_lib}" ] ; then
  tiff_libwebp_cmake="-DWEBP_LIBRARY=${tiff_prefix}/lib/${tiff_libwebp_lib} -DWEBP_INCLUDE_DIR=${tiff_prefix}/include"
fi

if [ ${debug} -gt 0 ] ; then
  echo ''
  module list
  echo ''
  echo cmake -L -G \"Unix Makefiles\" \
      -DJPEG_LIBRARY=${opt}/libjpeg-turbo-${tiff_libjpegturbo_ver}/lib/${tiff_libjpegturbo_lib} -DJPEG_INCLUDE_DIR=${opt}/libjpeg-turbo-${tiff_libjpegturbo_ver}/include \
      -DJBIG_LIBRARY=${opt}/jbigkit-${tiff_jbigkit_ver}/lib/${tiff_jbigkit_lib} -DJBIG_INCLUDE_DIR=${opt}/jbigkit-${tiff_jbigkit_ver}/include \
      -DZLIB_LIBRARY=${opt}/zlib-${tiff_zlib_ver}/lib/${tiff_zlib_lib} -DZLIB_INCLUDE_DIR=${opt}/zlib-${tiff_zlib_ver}/include \
      -DLIBLZMA_LIBRARY=${opt}/xz-${tiff_xz_ver}/lib/${tiff_xz_lib} -DLIBLZMA_INCLUDE_DIR=${opt}/xz-${tiff_xz_ver}/include \
      -DZSTD_LIBRARY=${opt}/zstd-${tiff_zstd_ver}/lib/${tiff_zstd_lib} -DZSTD_INCLUDE_DIR=${opt}/zstd-${tiff_zstd_ver}/include \
      ${tiff_libwebp_cmake} \
      -DCMAKE_INSTALL_PREFIX=${tiff_prefix} ..
  read k
fi

cmake -L -G "Unix Makefiles" \
      -DJPEG_LIBRARY=${opt}/libjpeg-turbo-${tiff_libjpegturbo_ver}/lib/${tiff_libjpegturbo_lib} -DJPEG_INCLUDE_DIR=${opt}/libjpeg-turbo-${tiff_libjpegturbo_ver}/include \
      -DJBIG_LIBRARY=${opt}/jbigkit-${tiff_jbigkit_ver}/lib/${tiff_jbigkit_lib} -DJBIG_INCLUDE_DIR=${opt}/jbigkit-${tiff_jbigkit_ver}/include \
      -DZLIB_LIBRARY=${opt}/zlib-${tiff_zlib_ver}/lib/${tiff_zlib_lib} -DZLIB_INCLUDE_DIR=${opt}/zlib-${tiff_zlib_ver}/include \
      -DLIBLZMA_LIBRARY=${opt}/xz-${tiff_xz_ver}/lib/${tiff_xz_lib} -DLIBLZMA_INCLUDE_DIR=${opt}/xz-${tiff_xz_ver}/include \
      -DZSTD_LIBRARY=${opt}/zstd-${tiff_zstd_ver}/lib/${tiff_zstd_lib} -DZSTD_INCLUDE_DIR=${opt}/zstd-${tiff_zstd_ver}/include \
      ${tiff_libwebp_cmake} \
      -DCMAKE_INSTALL_PREFIX=${tiff_prefix} ..

else

config="./configure --prefix=${tiff_prefix} \
        --with-jpeg-lib-dir=${opt}/libjpeg-turbo-${tiff_libjpegturbo_ver}/lib \
        --with-jbig-lib-dir=${opt}/jbigkit-${tiff_jbigkit_ver}/lib \
	--with-zlib-lib-dir=${opt}/zlib-${tiff_zlib_ver}/lib \
	--with-lzma-lib-dir=${opt}/xz-${tiff_xz_ver}/lib"

if [ ${debug} -gt 0 ] ; then
  ./configure --help
  echo ''
  module list
  echo ''
  echo ${config}
  read k
fi

${config}

fi

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
  make test
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
rm -rf ${tmp}/${tiff_srcdir}

}
