#!/bin/bash

# Functions for detecting and building libjpeg-turbo
echo 'Loading libjpeg-turbo...'

function libjpegturboInstalled() {
# Cannot evaulate if we dont have modules installed
if [ ! -f /etc/profile.d/modules.sh ] ; then
  return 1
fi
# Load modules if not loaded already
if [ -z "${MODULEPATH}" ] ; then
  source /etc/profile.d/modules.sh
fi 
# If modules is OK, then check libjpeg-turbo
if [ ! -f ${MODULEPATH}/libjpeg-turbo/${1} ] ; then
  return 1
else
  return 0
fi
}

function check_libjpegturbo() {
if libjpegturboInstalled ${1}; then
  echo "libjpeg-turbo ${1} is installed."
else
  build_libjpegturbo ${1}
fi
}

function build_libjpegturbo() {

# Get desired version number to install
libjpegturbo_v=${1}
if [ -z "${libjpegturbo_v}" ] ; then
  libjpegturbo_v=4.1.0
fi

case ${libjpegturbo_v} in
  1.5.2) # 2017-08-09
   libjpegturbo_nasm_ver=2.13.01 # 2017-05-01
  ;;
  2.0.3) # 2019-09-04
   libjpegturbo_nasm_ver=2.14.02 # 2018-12-26
  ;;
  *)
   echo "ERROR: Review needed for libjpeg-turbo ${libjpegturbo_v}"
   exit 4 # Please review
  ;;
esac

## Optimized dependency strategy
#if [ "${dependency_strategy}" == "optimized" ] ; then
#  tiff_zlib_ver=${global_zlib}
#  tiff_xz_ver=${global_xz}
#fi

echo "Installing libjpeg-turbo ${libjpegturbo_v}..."
libjpegturbo_srcdir=libjpeg-turbo-${libjpegturbo_v}

check_modules
check_nasm ${libjpegturbo_nasm_ver}

downloadPackage libjpeg-turbo-${libjpegturbo_v}.tar.gz

cd ${tmp}

if [ -d ${tmp}/${libjpegturbo_srcdir} ] ; then
  rm -rf ${tmp}/${libjpegturbo_srcdir}
fi

cd ${tmp}
tar xvfz ${pkg}/libjpeg-turbo-${libjpegturbo_v}.tar.gz
cd ${tmp}/${libjpegturbo_srcdir}

if [ ${debug} -gt 0 ] ; then
  echo '>> Unzip complete'
  read k
fi

module purge
module load nasm/${libjpegturbo_nasm_ver}

config="./configure --prefix=${opt}/libjpeg-turbo-${libjpegturbo_v}"
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
mkdir -pv ${MODULEPATH}/libjpeg-turbo
cat << eof > ${MODULEPATH}/libjpeg-turbo/${libjpegturbo_v}
#%Module

proc ModulesHelp { } {
   puts stderr "Puts libjpeg-turbo-${libjpegturbo_v} into your environment"
}

set VER ${libjpegturbo_v}
set PKG ${opt}/libjpeg-turbo-\$VER

module-whatis   "Loads libjpeg-turbo-${libjpegturbo_v}"
conflict libjpeg-turbo

prepend-path CPATH \$PKG/include
prepend-path C_INCLUDE_PATH \$PKG/include
prepend-path CPLUS_INCLUDE_PATH \$PKG/include
prepend-path LD_LIBRARY_PATH \$PKG/lib
prepend-path PKG_CONFIG_PATH \$PKG/lib/pkgconfig
prepend-path PATH \$PKG/bin
prepend-path MANPATH \$PKG/share/man

eof

cd ${root}
rm -rf ${tmp}/${libjpegturbo_srcdir}

}
