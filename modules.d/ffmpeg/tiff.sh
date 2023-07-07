#!/bin/bash

# Functions for detecting and building tiff
echo 'Loading tiff...'

function tiffInstalled() {
# Cannot evaulate if we dont have modules installed
if [ ! -f /etc/profile.d/modules.sh ] ; then
  return 1
fi
# Load modules if not loaded already
if [ -z "${MODULEPATH}" ] ; then
  source /etc/profile.d/modules.sh
fi 
# If modules is OK, then check tiff
if [ ! -f ${MODULEPATH}/tiff/${1} ] ; then
  return 1
else
  return 0
fi
}

function tiffDepInstalled() {
  return 1
}

function check_tiff() {
if tiffInstalled ${1}; then
  echo "tiff ${1} is installed."
else
  build_tiff ${1}
fi
}

function ff_check_tiff() {
echo -n "Checking for presence of tiff-${1} in ${2}..."
if tiffDepInstalled ${1} ${2}; then
  echo "present"
else
  echo "not present"
  ff_build_tiff ${1} ${2} ${3} ${4} ${5}
fi
}

function build_tiff() {

tiff_use_cmake=1

# Get desired version number to install
tiff_v=${1}
if [ -z "${tiff_v}" ] ; then
  tiff_v=4.1.0
fi

case ${tiff_v} in
  4.0.9) # 2017-Nov-18
   tiff_cmake_ver=3.9.6 # 2017-11-10
   tiff_libjpeg_ver=9b # Sun Jan 17 10:46 2016
   tiff_libjpegturbo_ver=1.5.2 # 2017-08-09
   tiff_zlib_ver=1.2.11 # 2017-01-15
   tiff_xz_ver=5.2.3    # 2016-12-30
   tiff_jbigkit_ver=2.1 # 2014-04-08
  ;;
  4.1.0) # 2019-Nov-03
   tiff_cmake_ver=3.15.5 # 2019-10-30
   tiff_libjpeg_ver=9c # Sun Jan 14 11:48 2018
   tiff_libjpegturbo_ver=2.0.3 # 2019-09-04
   tiff_zlib_ver=1.2.11 # 2017-01-15
   tiff_xz_ver=5.2.4    # 2018-04-29
   tiff_jbigkit_ver=2.1 # 2014-04-08
  ;;
  4.4.0) # 2022-May-27 14:53
   tiff_cmake_ver=3.21.6 # 2022-03-04
   tiff_libjpeg_ver=9e # Sun Jan 16 10:30 2022
   tiff_libjpegturbo_ver=2.1.3 # 2022-02-25
   tiff_zlib_ver=1.2.11 # 2017-01-15
   tiff_xz_ver=5.2.5    # 2020-03-17
   tiff_jbigkit_ver=2.1 # 2014-04-08
  ;;
  *)
   echo "ERROR: Review needed for tiff ${tiff_v}"
   exit 4 # Please review
  ;;
esac

# Optimized dependency strategy
if [ "${dependency_strategy}" == "optimized" ] ; then
  tiff_zlib_ver=${global_zlib}
  tiff_xz_ver=${global_xz}
fi

case ${tiff_libjpegturbo_ver} in
  1.5.2)
    tiff_libjpegturbo_lib=libjpeg.so.62.2.0
  ;;
  2.0.3)
    tiff_libjpegturbo_lib=libjpeg.so.62.3.0
  ;;
  *)
    echo "ERROR: Unknown libjpegturbo library"
    exit 3
  ;;
esac
case ${tiff_zlib_ver} in
  1.2.13)
    tiff_zlib_lib=libz.so.${tiff_zlib_ver}
  ;;
  *)
    echo "ERROR: Unknown zlib library"
    exit 3
  ;;
esac
case ${tiff_xz_ver} in
  5.4.2)
    tiff_xz_lib=liblzma.so.${tiff_xz_ver}
  ;;
  *)
    echo "ERROR: Unknown xz library"
    exit 3
  ;;
esac
case ${tiff_jbigkit_ver} in
  2.1)
    tiff_jbigkit_lib=libjbig.so.0
  ;;
  *)
    echo "ERROR: Unknown jbigkit library"
    exit 3
  ;;
esac

echo "Installing tiff ${tiff_v}..."
tiff_srcdir=tiff-${tiff_v}

check_modules
if [ ${tiff_use_cmake} -gt 0 ] ; then
  check_cmake ${tiff_cmake_ver}
fi
#check_libjpeg ${tiff_libjpeg_ver}
check_libjpegturbo ${tiff_libjpegturbo_ver}
check_zlib ${tiff_zlib_ver}
check_xz ${tiff_xz_ver}
check_jbigkit ${tiff_jbigkit_ver}

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
if [ ${tiff_use_cmake} -gt 0 ] ; then
  module load cmake/${tiff_cmake_ver}
fi
module load libjpeg-turbo/${tiff_libjpegturbo_ver}
#module load libjpeg/${tiff_libjpeg_ver}
module load zlib/${tiff_zlib_ver}
module load xz/${tiff_xz_ver}
module load jbigkit/${tiff_jbigkit_ver}


if [ ${tiff_use_cmake} -gt 0 ] ; then

if [ ! -d ${tmp}/${tiff_srcdir}/build ] ; then
  mkdir -v ${tmp}/${tiff_srcdir}/build
fi
cd ${tmp}/${tiff_srcdir}/build

if [ ${debug} -gt 0 ] ; then
  echo ''
  module list
  echo ''
  echo cmake -L -G \"Unix Makefiles\" \
      -DJPEG_LIBRARY=${opt}/libjpeg-turbo-${tiff_libjpegturbo_ver}/lib/${tiff_libjpegturbo_lib} -DJPEG_INCLUDE_DIR=${opt}/libjpeg-turbo-${tiff_libjpegturbo_ver}/include \
      -DJBIG_LIBRARY=${opt}/jbigkit-${tiff_jbigkit_ver}/lib/${tiff_jbigkit_lib} -DJBIG_INCLUDE_DIR=${opt}/jbigkit-${tiff_jbigkit_ver}/include \
      -DZLIB_LIBRARY=${opt}/zlib-${tiff_zlib_ver}/lib/${tiff_zlib_lib} -DZLIB_INCLUDE_DIR=${opt}/zlib-${tiff_zlib_ver}/include \
      -DLIBLZMA_LIBRARY=${opt}/xz-${tiff_xz_ver}/lib/${tiff_xz_lib} -DLIBLZMA_INCLUDE_DIR=${opt}/xz-${tiff_xz_ver}/include \
      -DCMAKE_INSTALL_PREFIX=${opt}/tiff-${tiff_v} ..
  read k
fi

cmake -L -G "Unix Makefiles" \
      -DJPEG_LIBRARY=${opt}/libjpeg-turbo-${tiff_libjpegturbo_ver}/lib/${tiff_libjpegturbo_lib} -DJPEG_INCLUDE_DIR=${opt}/libjpeg-turbo-${tiff_libjpegturbo_ver}/include \
      -DJBIG_LIBRARY=${opt}/jbigkit-${tiff_jbigkit_ver}/lib/${tiff_jbigkit_lib} -DJBIG_INCLUDE_DIR=${opt}/jbigkit-${tiff_jbigkit_ver}/include \
      -DZLIB_LIBRARY=${opt}/zlib-${tiff_zlib_ver}/lib/${tiff_zlib_lib} -DZLIB_INCLUDE_DIR=${opt}/zlib-${tiff_zlib_ver}/include \
      -DLIBLZMA_LIBRARY=${opt}/xz-${tiff_xz_ver}/lib/${tiff_xz_lib} -DLIBLZMA_INCLUDE_DIR=${opt}/xz-${tiff_xz_ver}/include \
      -DCMAKE_INSTALL_PREFIX=${opt}/tiff-${tiff_v} ..
else

config="./configure --prefix=${opt}/tiff-${tiff_v} \
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

# Create the environment module
if [ -z "${MODULEPATH}" ] ; then
  source /etc/profile.d/modules.sh
fi 
mkdir -pv ${MODULEPATH}/tiff
cat << eof > ${MODULEPATH}/tiff/${tiff_v}
#%Module

proc ModulesHelp { } {
   puts stderr "Puts tiff-${tiff_v} into your environment"
}

set VER ${tiff_v}
set PKG ${opt}/tiff-\$VER

module-whatis   "Loads tiff-${tiff_v}"
conflict tiff
#module load libjpeg/${tiff_libjpeg_ver}
module load libjpeg-turbo/${tiff_libjpegturbo_ver}
module load zlib/${tiff_zlib_ver}
module load xz/${tiff_xz_ver}
module load jbigkit/${tiff_jbigkit_ver}
#prereq libjpeg/${tiff_libjpeg_ver}
prereq libjpeg-turbo/${tiff_libjpegturbo_ver}
prereq zlib/${tiff_zlib_ver}
prereq xz/${tiff_xz_ver}
prereq jbigkit/${tiff_jbigkit_ver}

prepend-path CPATH \$PKG/include
prepend-path C_INCLUDE_PATH \$PKG/include
prepend-path CPLUS_INCLUDE_PATH \$PKG/include
prepend-path LD_LIBRARY_PATH \$PKG/lib
prepend-path PKG_CONFIG_PATH \$PKG/lib/pkgconfig
prepend-path PATH \$PKG/bin
prepend-path MANPATH \$PKG/share/man

eof

cd ${root}
rm -rf ${tmp}/${tiff_srcdir}

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

tiff_zlib_ver=${global_zlib}
tiff_xz_ver=${global_xz}
tiff_ffmpeg_ver=${3}
tiff_jbigkit_ver=${4}
tiff_libjpegturbo_ver=${5}

tiff_zlib_lib=$(get_zlib_library ${tiff_zlib_ver})
tiff_xz_lib=$(get_xz_library ${tiff_xz_ver})
tiff_jbigkit_lib=$(get_jbigkit_library ${tiff_jbigkit_ver})
tiff_libjpegturbo_lib=$(get_libjpegturbo_library ${tiff_libjpegturbo_ver})

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
if [ ${tiff_use_cmake} -gt 0 ] ; then
  module load cmake/${tiff_cmake_ver}
fi
module load libjpeg-turbo/${tiff_libjpegturbo_ver}
module load zlib/${tiff_zlib_ver}
module load xz/${tiff_xz_ver}
module load jbigkit/${tiff_jbigkit_ver}
module load ffmpeg-dep/${tiff_ffmpeg_ver}

if [ ${tiff_use_cmake} -gt 0 ] ; then

if [ ! -d ${tmp}/${tiff_srcdir}/build ] ; then
  mkdir -v ${tmp}/${tiff_srcdir}/build
fi
cd ${tmp}/${tiff_srcdir}/build

if [ ${debug} -gt 0 ] ; then
  echo ''
  module list
  echo ''
  echo cmake -L -G \"Unix Makefiles\" \
      -DJPEG_LIBRARY=${opt}/libjpeg-turbo-${tiff_libjpegturbo_ver}/lib/${tiff_libjpegturbo_lib} -DJPEG_INCLUDE_DIR=${opt}/libjpeg-turbo-${tiff_libjpegturbo_ver}/include \
      -DJBIG_LIBRARY=${opt}/jbigkit-${tiff_jbigkit_ver}/lib/${tiff_jbigkit_lib} -DJBIG_INCLUDE_DIR=${opt}/jbigkit-${tiff_jbigkit_ver}/include \
      -DZLIB_LIBRARY=${opt}/zlib-${tiff_zlib_ver}/lib/${tiff_zlib_lib} -DZLIB_INCLUDE_DIR=${opt}/zlib-${tiff_zlib_ver}/include \
      -DLIBLZMA_LIBRARY=${opt}/xz-${tiff_xz_ver}/lib/${tiff_xz_lib} -DLIBLZMA_INCLUDE_DIR=${opt}/xz-${tiff_xz_ver}/include \
      -DCMAKE_INSTALL_PREFIX=${tiff_prefix} ..
  read k
fi

cmake -L -G "Unix Makefiles" \
      -DJPEG_LIBRARY=${opt}/libjpeg-turbo-${tiff_libjpegturbo_ver}/lib/${tiff_libjpegturbo_lib} -DJPEG_INCLUDE_DIR=${opt}/libjpeg-turbo-${tiff_libjpegturbo_ver}/include \
      -DJBIG_LIBRARY=${opt}/jbigkit-${tiff_jbigkit_ver}/lib/${tiff_jbigkit_lib} -DJBIG_INCLUDE_DIR=${opt}/jbigkit-${tiff_jbigkit_ver}/include \
      -DZLIB_LIBRARY=${opt}/zlib-${tiff_zlib_ver}/lib/${tiff_zlib_lib} -DZLIB_INCLUDE_DIR=${opt}/zlib-${tiff_zlib_ver}/include \
      -DLIBLZMA_LIBRARY=${opt}/xz-${tiff_xz_ver}/lib/${tiff_xz_lib} -DLIBLZMA_INCLUDE_DIR=${opt}/xz-${tiff_xz_ver}/include \
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
}
