#!/bin/bash

# Functions for detecting and building libvorbis
echo 'Loading libvorbis...'

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

case ${1} in
  1.3.6)              # 2018-03-16
   libogg_ver=1.3.3   # 2017-11-07
   doxygen_ver=1.8.14 # 2017-12-25
  ;;
  1.3.7)              # 2020-07-04
   libogg_ver=1.3.4   # 2019-08-30
   doxygen_ver=1.8.17 # 2019-12-27
  ;;
  *)
   echo "ERROR: Review needed for libvorbis ${1}"
   exit 4 # Please review
  ;;
esac

# Optimized dependency strategy
if [ "${dependency_strategy}" == "optimized" ] ; then
  libogg_ver=${global_libogg}
fi

echo "Installing libvorbis ${libvorbis_v}..."

check_modules
check_libogg ${libogg_ver}
check_doxygen ${doxygen_ver}

downloadPackage libvorbis-${libvorbis_v}.tar.gz

cd ${tmp}

if [ -d ${tmp}/${libvorbis_srcdir} ] ; then
  rm -rf ${tmp}/${libvorbis_srcdir}
fi

cd ${tmp}
tar xvfz ${pkg}/libvorbis-${libvorbis_v}.tar.gz
cd ${tmp}/${libvorbis_srcdir}

module purge
module load libogg/${libogg_ver}
module load doxygen/${doxygen_ver}

config="./configure --prefix=${opt}/libvorbis-${libvorbis_v}"
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
module load libogg/${libogg_ver}
prereq libogg/${libogg_ver}

prepend-path CPATH \$PKG/include
prepend-path C_INCLUDE_PATH \$PKG/include
prepend-path CPLUS_INCLUDE_PATH \$PKG/include
prepend-path LD_LIBRARY_PATH \$PKG/lib
prepend-path PKG_CONFIG_PATH \$PKG/lib/pkgconfig

eof

cd ${root}
rm -rf ${tmp}/${libvorbis_srcdir}

}
