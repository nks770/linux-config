#!/bin/bash

# Functions for detecting and building libjpeg
echo 'Loading libjpeg...'

function libjpegInstalled() {
# Cannot evaulate if we dont have modules installed
if [ ! -f /etc/profile.d/modules.sh ] ; then
  return 1
fi
# Load modules if not loaded already
if [ -z "${MODULEPATH}" ] ; then
  source /etc/profile.d/modules.sh
fi 
# If modules is OK, then check libjpeg
if [ ! -f ${MODULEPATH}/libjpeg/${1} ] ; then
  return 1
else
  return 0
fi
}

function check_libjpeg() {
if libjpegInstalled ${1}; then
  echo "libjpeg ${1} is installed."
else
  build_libjpeg ${1}
fi
}

function build_libjpeg() {

# Get desired version number to install
libjpeg_v=${1}
if [ -z "${libjpeg_v}" ] ; then
  libjpeg_v=9d
fi

#case ${1} in
#  9c)
#   libjpeg_libogg_ver=1.3.4
#   libjpeg_libvorbis_ver=1.3.7
#   libjpeg_flac_ver=1.3.3
#  ;;
#esac

echo "Installing libjpeg ${libjpeg_v}..."
libjpeg_srcdir=jpeg-${libjpeg_v}

check_modules

downloadPackage jpegsrc.v${libjpeg_v}.tar.gz

cd ${tmp}

if [ -d ${tmp}/${libjpeg_srcdir} ] ; then
  rm -rf ${tmp}/${libjpeg_srcdir}
fi

cd ${tmp}
tar xvfz ${pkg}/jpegsrc.v${libjpeg_v}.tar.gz
cd ${tmp}/${libjpeg_srcdir}

if [ ${debug} -gt 0 ] ; then
  echo '>> Unzip complete'
  read k
fi

module purge

config="./configure --prefix=${opt}/libjpeg-${libjpeg_v}"
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
mkdir -pv ${MODULEPATH}/libjpeg
cat << eof > ${MODULEPATH}/libjpeg/${libjpeg_v}
#%Module

proc ModulesHelp { } {
   puts stderr "Puts libjpeg-${libjpeg_v} into your environment"
}

set VER ${libjpeg_v}
set PKG ${opt}/libjpeg-\$VER

module-whatis   "Loads libjpeg-${libjpeg_v}"
conflict libjpeg

prepend-path CPATH \$PKG/include
prepend-path C_INCLUDE_PATH \$PKG/include
prepend-path CPLUS_INCLUDE_PATH \$PKG/include
prepend-path LD_LIBRARY_PATH \$PKG/lib
prepend-path PKG_CONFIG_PATH \$PKG/lib/pkgconfig
prepend-path PATH \$PKG/bin
prepend-path MANPATH \$PKG/share/man

eof

cd ${root}
rm -rf ${tmp}/${libjpeg_srcdir}

}
