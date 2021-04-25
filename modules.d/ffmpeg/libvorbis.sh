#!/bin/bash

# Functions for detecting and building libvorbis

function libvorbisInstalled() {
# Cannot evaulate if we dont have modules installed
if [ ! -f /etc/profile.d/modules.sh ] ; then
  return 1
fi
# Load modules if not loaded already
if [ -z "${MODULEPATH}" ] ; then
  source /etc/profile.d/modules.sh
fi 
# If modules is OK, then check libvorbis
if [ ! -f ${MODULEPATH}/libvorbis/${1} ] ; then
  return 1
else
  return 0
fi
}

function check_libvorbis() {
if libvorbisInstalled ${1}; then
  echo "libvorbis ${1} is installed."
else
  build_libvorbis ${1}
fi
}

function build_libvorbis() {

# Get desired version number to install
libvorbis_v=${1}
if [ -z "${libvorbis_v}" ] ; then
  libvorbis_v=1.3.7
fi
libvorbis_srcdir=libvorbis-${libvorbis_v}

echo "Installing libvorbis ${libvorbis_v}..."

case ${1} in
  1.3.7) # 2020-07-04
   libvorbis_libogg_ver=1.3.4
  ;;
esac

check_modules
check_libogg ${libvorbis_libogg_ver}

module purge
module load libogg/${libvorbis_libogg_ver}
module list

downloadPackage libvorbis-${libvorbis_v}.tar.gz

cd ${tmp}

if [ -d ${tmp}/${libvorbis_srcdir} ] ; then
  rm -rf ${tmp}/${libvorbis_srcdir}
fi

cd ${tmp}
tar xvfz ${pkg}/libvorbis-${libvorbis_v}.tar.gz
cd ${tmp}/${libvorbis_srcdir}

./configure --prefix=${opt}/libvorbis-${libvorbis_v}
make -j ${ncpu} && make install

if [ ! $? -eq 0 ] ; then
  exit 4
fi

# Create the environment module
if [ -z "${MODULEPATH}" ] ; then
  source /etc/profile.d/modules.sh
fi 
mkdir -pv ${MODULEPATH}/libvorbis
cat << eof > ${MODULEPATH}/libvorbis/${libvorbis_v}
#%Module

proc ModulesHelp { } {
   puts stderr "Puts libvorbis-${libvorbis_v} into your environment"
}

set VER ${libvorbis_v}
set PKG ${opt}/libvorbis-\$VER

module-whatis   "Loads libvorbis-${libvorbis_v}"
conflict libvorbis

prepend-path CPATH \$PKG/include
prepend-path C_INCLUDE_PATH \$PKG/include
prepend-path CPLUS_INCLUDE_PATH \$PKG/include
prepend-path LD_LIBRARY_PATH \$PKG/lib
prepend-path PKG_CONFIG_PATH \$PKG/lib/pkgconfig

eof

cd ${root}
rm -rf ${tmp}/${libvorbis_srcdir}

}
