#!/bin/bash

# Functions for detecting and building openjpeg

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
openjpeg_srcdir=openjpeg-${openjpeg_v}

echo "Installing openjpeg ${openjpeg_v}..."

case ${1} in
  2.3.1) # Apr 2, 2019
   openjpeg_cmake_ver=3.13.4 # 2019-02-01 13:20
  ;;
esac

check_modules
check_cmake ${openjpeg_cmake_ver}

module purge
module load cmake/${openjpeg_cmake_ver}
module list

downloadPackage openjpeg-${openjpeg_v}.tar.gz

cd ${tmp}

if [ -d ${tmp}/${openjpeg_srcdir} ] ; then
  rm -rf ${tmp}/${openjpeg_srcdir}
fi

cd ${tmp}
tar xvfz ${pkg}/openjpeg-${openjpeg_v}.tar.gz
cd ${tmp}/${openjpeg_srcdir}

cmake -G 'Unix Makefiles' -DCMAKE_INSTALL_PREFIX=${opt}/openjpeg-${openjpeg_v}
make -j ${ncpu} && make install

if [ ! $? -eq 0 ] ; then
  exit 4
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
