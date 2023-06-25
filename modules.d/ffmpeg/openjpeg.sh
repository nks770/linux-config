#!/bin/bash

# Functions for detecting and building openjpeg
echo 'Loading openjpeg...'

function openjpegInstalled() {
# Cannot evaulate if we dont have modules installed
if [ ! -f /etc/profile.d/modules.sh ] ; then
  return 1
fi
# Load modules if not loaded already
if [ -z "${MODULEPATH}" ] ; then
  source /etc/profile.d/modules.sh
fi 
# If modules is OK, then check openjpeg
if [ ! -f ${MODULEPATH}/openjpeg/${1} ] ; then
  return 1
else
  return 0
fi
}

function check_openjpeg() {
if openjpegInstalled ${1}; then
  echo "openjpeg ${1} is installed."
else
  build_openjpeg ${1}
fi
}

function build_openjpeg() {

# Get desired version number to install
openjpeg_v=${1}
if [ -z "${openjpeg_v}" ] ; then
  openjpeg_v=2.3.1
fi

case ${openjpeg_v} in
  2.3.1) # Apr 2, 2019
   openjpeg_cmake_ver=3.13.4  # 2019-02-01 13:20
   openjpeg_zlib_ver=1.2.11   # 2017-01-15
   openjpeg_libpng_ver=1.6.36 # 2018-12-02
   openjpeg_tiff_ver=4.0.9    # 2017-11-18
   openjpeg_lcms2_ver=2.9     # 2017-11-06
  ;;
  2.5.0) # May 13, 2022
   openjpeg_cmake_ver=3.23.1  # 2022-04-12 10:55
   openjpeg_zlib_ver=1.2.12   # 2022-03-27
   openjpeg_libpng_ver=1.6.37 # 2019-04-15
   openjpeg_tiff_ver=4.3.0    # 2021-04-20
   openjpeg_lcms2_ver=2.13.1  # 2022-02-03
  ;;
  *)
   echo "ERROR: Review needed for openjpeg ${openjpeg_v}"
   exit 4 # Please review
  ;;
esac

# Optimized dependency strategy
if [ "${dependency_strategy}" == "optimized" ] ; then
  openjpeg_zlib_ver=${global_zlib}
fi

echo "Installing openjpeg ${openjpeg_v}..."
openjpeg_srcdir=openjpeg-${openjpeg_v}

case ${openjpeg_zlib_ver} in
  1.2.13)
    openjpeg_zlib_lib=libz.so.${openjpeg_zlib_ver}
  ;;
  *)
    echo "ERROR: Unknown zlib library"
    exit 3
  ;;
esac
case ${openjpeg_libpng_ver} in
  1.6.36)
    openjpeg_libpng_lib=libpng16.so.16.36.0
  ;;
  *)
    echo "ERROR: Unknown libpng library"
    exit 3
  ;;
esac
case ${openjpeg_tiff_ver} in
  4.0.9)
    openjpeg_tiff_lib=libtiff.so.5.3.0
  ;;
  *)
    echo "ERROR: Unknown tiff library"
    exit 3
  ;;
esac
case ${openjpeg_lcms2_ver} in
  2.9)
    openjpeg_lcms2_lib=liblcms2.so.2.0.8
  ;;
  *)
    echo "ERROR: Unknown lcms2 library"
    exit 3
  ;;
esac

check_modules
check_cmake ${openjpeg_cmake_ver}
check_zlib ${openjpeg_zlib_ver}
check_libpng ${openjpeg_libpng_ver}
check_tiff ${openjpeg_tiff_ver}
check_lcms2 ${openjpeg_lcms2_ver}

downloadPackage openjpeg-${openjpeg_v}.tar.gz

cd ${tmp}

if [ -d ${tmp}/${openjpeg_srcdir} ] ; then
  rm -rf ${tmp}/${openjpeg_srcdir}
fi

cd ${tmp}
tar xvfz ${pkg}/openjpeg-${openjpeg_v}.tar.gz
mkdir -pv ${tmp}/${openjpeg_srcdir}/build
cd ${tmp}/${openjpeg_srcdir}/build

if [ ${debug} -gt 0 ] ; then
  echo '>> Unzip complete'
  read k
fi

module purge
module load cmake/${openjpeg_cmake_ver}
module load zlib/${openjpeg_zlib_ver}
module load libpng/${openjpeg_libpng_ver}
module load tiff/${openjpeg_tiff_ver}
module load lcms2/${openjpeg_lcms2_ver}

if [ ${debug} -gt 0 ] ; then
  echo ''
  module list
  echo cmake -L -G \"Unix Makefiles\" \
       -DZLIB_LIBRARY=${opt}/zlib-${openjpeg_zlib_ver}/lib/${openjpeg_zlib_lib} \
       -DZLIB_INCLUDE_DIR=${opt}/zlib-${openjpeg_zlib_ver}/include \
       -DPNG_LIBRARY=${opt}/libpng-${openjpeg_libpng_ver}/lib/${openjpeg_libpng_lib} \
       -DPNG_PNG_INCLUDE_DIR=${opt}/libpng-${openjpeg_libpng_ver}/include \
       -DTIFF_LIBRARY=${opt}/tiff-${openjpeg_tiff_ver}/lib/${openjpeg_tiff_lib} \
       -DTIFF_INCLUDE_DIR=${opt}/tiff-${openjpeg_tiff_ver}/include \
       -DLCMS2_LIBRARY=${opt}/lcms2-${openjpeg_lcms2_ver}/lib/${openjpeg_lcms2_lib} \
       -DLCMS2_INCLUDE_DIR=${opt}/lcms2-${openjpeg_lcms2_ver}/include \
       -DCMAKE_INSTALL_PREFIX=${opt}/openjpeg-${openjpeg_v} ..
  echo ''
  read k
fi

cmake -L -G 'Unix Makefiles' \
       -DZLIB_LIBRARY=${opt}/zlib-${openjpeg_zlib_ver}/lib/${openjpeg_zlib_lib} \
       -DZLIB_INCLUDE_DIR=${opt}/zlib-${openjpeg_zlib_ver}/include \
       -DPNG_LIBRARY=${opt}/libpng-${openjpeg_libpng_ver}/lib/${openjpeg_libpng_lib} \
       -DPNG_PNG_INCLUDE_DIR=${opt}/libpng-${openjpeg_libpng_ver}/include \
       -DTIFF_LIBRARY=${opt}/tiff-${openjpeg_tiff_ver}/lib/${openjpeg_tiff_lib} \
       -DTIFF_INCLUDE_DIR=${opt}/tiff-${openjpeg_tiff_ver}/include \
       -DLCMS2_LIBRARY=${opt}/lcms2-${openjpeg_lcms2_ver}/lib/${openjpeg_lcms2_lib} \
       -DLCMS2_INCLUDE_DIR=${opt}/lcms2-${openjpeg_lcms2_ver}/include \
       -DCMAKE_INSTALL_PREFIX=${opt}/openjpeg-${openjpeg_v} ..

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

## openjpeg does not appear to have a test suite
#if [ ${run_tests} -gt 0 ] ; then
#  make check
#  echo '>> Tests complete'
#  read k
#fi

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
mkdir -pv ${MODULEPATH}/openjpeg
cat << eof > ${MODULEPATH}/openjpeg/${openjpeg_v}
#%Module

proc ModulesHelp { } {
   puts stderr "Puts openjpeg-${openjpeg_v} into your environment"
}

set VER ${openjpeg_v}
set PKG ${opt}/openjpeg-\$VER

module-whatis   "Loads openjpeg-${openjpeg_v}"
conflict openjpeg
module load zlib/${openjpeg_zlib_ver}
module load libpng/${openjpeg_libpng_ver}
prereq zlib/${openjpeg_zlib_ver}
prereq libpng/${openjpeg_libpng_ver}

prepend-path CPATH \$PKG/include
prepend-path C_INCLUDE_PATH \$PKG/include
prepend-path CPLUS_INCLUDE_PATH \$PKG/include
prepend-path LD_LIBRARY_PATH \$PKG/lib
prepend-path PKG_CONFIG_PATH \$PKG/lib/pkgconfig
prepend-path PATH \$PKG/bin

eof

cd ${root}
rm -rf ${tmp}/${openjpeg_srcdir}

}
