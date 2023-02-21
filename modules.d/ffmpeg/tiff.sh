#!/bin/bash

# Functions for detecting and building tiff

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

function check_tiff() {
if tiffInstalled ${1}; then
  echo "tiff ${1} is installed."
else
  build_tiff ${1}
fi
}

function build_tiff() {

# Get desired version number to install
tiff_v=${1}
if [ -z "${tiff_v}" ] ; then
  tiff_v=4.1.0
fi
tiff_srcdir=tiff-${tiff_v}

echo "Installing tiff ${tiff_v}..."

case ${1} in
  4.1.0) # 2019-Nov-03
   tiff_libjpeg_ver=9c # Sun Jan 14 11:48 2018
  ;;
  4.4.0) # 2022-May-27 14:53
   tiff_libjpeg_ver=9e # Sun Jan 16 10:30 2022
  ;;
esac

check_modules
check_libjpeg ${tiff_libjpeg_ver}

module purge
module load libjpeg/${tiff_libjpeg_ver}
module list

downloadPackage tiff-${tiff_v}.tar.gz

cd ${tmp}

if [ -d ${tmp}/${tiff_srcdir} ] ; then
  rm -rf ${tmp}/${tiff_srcdir}
fi

cd ${tmp}
tar xvfz ${pkg}/tiff-${tiff_v}.tar.gz
cd ${tmp}/${tiff_srcdir}

./configure --prefix=${opt}/tiff-${tiff_v} \
            --with-jpeg-lib-dir=${opt}/libjpeg-${tiff_libjpeg_ver}/lib
make -j ${ncpu} && make install

if [ ! $? -eq 0 ] ; then
  exit 4
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
module load libjpeg/${tiff_libjpeg_ver}
prereq libjpeg/${tiff_libjpeg_ver}

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
