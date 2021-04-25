#!/bin/bash

# Functions for detecting and building libwebp

function libwebpInstalled() {
# Cannot evaulate if we dont have modules installed
if [ ! -f /etc/profile.d/modules.sh ] ; then
  return 1
fi
# Load modules if not loaded already
if [ -z "${MODULEPATH}" ] ; then
  source /etc/profile.d/modules.sh
fi 
# If modules is OK, then check libwebp
if [ ! -f ${MODULEPATH}/libwebp/${1} ] ; then
  return 1
else
  return 0
fi
}

function check_libwebp() {
if libwebpInstalled ${1}; then
  echo "libwebp ${1} is installed."
else
  build_libwebp ${1}
fi
}

function build_libwebp() {

# Get desired version number to install
libwebp_v=${1}
if [ -z "${libwebp_v}" ] ; then
  libwebp_v=1.0.3
fi
libwebp_srcdir=libwebp-${libwebp_v}

echo "Installing libwebp ${libwebp_v}..."

case ${1} in
  1.0.3) # Sat Jul 13 07:23:45 2019
   libwebp_libjpeg_ver=9c # Sun Jan 14 11:48 2018
   libwebp_tiff_ver=4.1.0 # 2019-Nov-03
   libwebp_giflib_ver=5.2.1 # 2019-06-24
  ;;
esac

check_modules
check_libjpeg ${libwebp_libjpeg_ver}
check_tiff ${libwebp_tiff_ver}
check_giflib ${libwebp_giflib_ver}

module purge
module load libjpeg/${libwebp_libjpeg_ver} \
            tiff/${libwebp_tiff_ver} \
            giflib/${libwebp_giflib_ver}
module list

downloadPackage libwebp-${libwebp_v}.tar.gz

cd ${tmp}

if [ -d ${tmp}/${libwebp_srcdir} ] ; then
  rm -rf ${tmp}/${libwebp_srcdir}
fi

cd ${tmp}
tar xvfz ${pkg}/libwebp-${libwebp_v}.tar.gz
cd ${tmp}/${libwebp_srcdir}

./configure --prefix=${opt}/libwebp-${libwebp_v} \
            --enable-libwebpmux \
            --enable-libwebpdecoder \
            --enable-libwebpextras \
            --enable-everything \
            --with-jpeglibdir=${opt}/libjpeg-${libwebp_libjpeg_ver}/lib \
            --with-tifflibdir=${opt}/tiff-${libwebp_tiff_ver}/lib \
            --with-gifincludedir=${opt}/giflib-${libwebp_giflib_ver}/include \
            --with-giflibdir=${opt}/giflib-${libwebp_giflib_ver}/lib
make -j ${ncpu} && make install

if [ ! $? -eq 0 ] ; then
  exit 4
fi

# Create the environment module
if [ -z "${MODULEPATH}" ] ; then
  source /etc/profile.d/modules.sh
fi 
mkdir -pv ${MODULEPATH}/libwebp
cat << eof > ${MODULEPATH}/libwebp/${libwebp_v}
#%Module

proc ModulesHelp { } {
   puts stderr "Puts libwebp-${libwebp_v} into your environment"
}

set VER ${libwebp_v}
set PKG ${opt}/libwebp-\$VER

module-whatis   "Loads libwebp-${libwebp_v}"
conflict libwebp
module load libjpeg/${libwebp_libjpeg_ver}
module load tiff/${libwebp_tiff_ver}
module load giflib/${libwebp_giflib_ver}
prereq libjpeg/${libwebp_libjpeg_ver}
prereq tiff/${libwebp_tiff_ver}
prereq giflib/${libwebp_giflib_ver}

prepend-path CPATH \$PKG/include
prepend-path C_INCLUDE_PATH \$PKG/include
prepend-path CPLUS_INCLUDE_PATH \$PKG/include
prepend-path LD_LIBRARY_PATH \$PKG/lib
prepend-path PKG_CONFIG_PATH \$PKG/lib/pkgconfig
prepend-path PATH \$PKG/bin
prepend-path MANPATH \$PKG/share/man

eof

cd ${root}
rm -rf ${tmp}/${libwebp_srcdir}

}
