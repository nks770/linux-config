#!/bin/bash

# Functions for detecting and building Little CMS
echo 'Loading Little CMS...'

function lcms2Installed() {
# Cannot evaulate if we dont have modules installed
if [ ! -f /etc/profile.d/modules.sh ] ; then
  return 1
fi
# Load modules if not loaded already
if [ -z "${MODULEPATH}" ] ; then
  source /etc/profile.d/modules.sh
fi 
# If modules is OK, then check lcms2
if [ ! -f ${MODULEPATH}/lcms2/${1} ] ; then
  return 1
else
  return 0
fi
}

function check_lcms2() {
if lcms2Installed ${1}; then
  echo "lcms2 ${1} is installed."
else
  build_lcms2 ${1}
fi
}

function build_lcms2() {

# Get desired version number to install
lcms2_v=${1}
if [ -z "${lcms2_v}" ] ; then
  lcms2_v=0.4.0
fi

case ${lcms2_v} in
  2.9) # 2017-11-06
   lcms2_tiff_ver=4.0.9
   lcms2_libjpegturbo_ver=1.5.2
   lcms2_zlib_ver=1.2.11        # 2017-01-15
  ;;
  *)
   echo "ERROR: Review needed for lcms2 ${lcms2_v}"
   exit 4 # Please review
  ;;
esac

# Optimized dependency strategy
if [ "${dependency_strategy}" == "optimized" ] ; then
  lcms2_zlib_ver=${global_zlib}
fi

echo "Installing lcms2 ${lcms2_v}..."
lcms2_srcdir=lcms2-${lcms2_v}

check_modules
check_zlib ${lcms2_zlib_ver}
check_tiff ${lcms2_tiff_ver}
check_libjpegturbo ${lcms2_libjpegturbo_ver}

downloadPackage lcms2-${lcms2_v}.tar.gz

cd ${tmp}

if [ -d ${tmp}/${lcms2_srcdir} ] ; then
  rm -rf ${tmp}/${lcms2_srcdir}
fi

cd ${tmp}
tar xvfz ${pkg}/lcms2-${lcms2_v}.tar.gz
cd ${tmp}/${lcms2_srcdir}

if [ ${debug} -gt 0 ] ; then
  echo '>> Unzip complete'
  read k
fi

module purge
module load zlib/${lcms2_zlib_ver}
module load tiff/${lcms2_tiff_ver}
module load libjpeg-turbo/${lcms2_libjpegturbo_ver}

config="./configure --prefix=${opt}/lcms2-${lcms2_v} --with-jpeg=${opt}/libjpeg-turbo-${lcms2_libjpegturbo_ver} --with-tiff=${opt}/tiff-${lcms2_tiff_ver} LDFLAGS=-L${opt}/zlib-${lcms2_zlib_ver}/lib"
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
mkdir -pv ${MODULEPATH}/lcms2
cat << eof > ${MODULEPATH}/lcms2/${lcms2_v}
#%Module

proc ModulesHelp { } {
   puts stderr "Puts lcms2-${lcms2_v} into your environment"
}

set VER ${lcms2_v}
set PKG ${opt}/lcms2-\$VER

module-whatis   "Loads lcms2-${lcms2_v}"
conflict lcms2
module load tiff/${lcms2_tiff_ver}
module load libjpeg-turbo/${lcms2_libjpegturbo_ver}
module load zlib/${lcms2_zlib_ver}
prereq tiff/${lcms2_tiff_ver}
prereq libjpeg-turbo/${lcms2_libjpegturbo_ver}
prereq zlib/${lcms2_zlib_ver}

prepend-path CPATH \$PKG/include
prepend-path C_INCLUDE_PATH \$PKG/include
prepend-path CPLUS_INCLUDE_PATH \$PKG/include
prepend-path LD_LIBRARY_PATH \$PKG/lib
prepend-path PKG_CONFIG_PATH \$PKG/lib/pkgconfig
prepend-path PATH \$PKG/bin
prepend-path MANPATH \$PKG/share/man

eof

cd ${root}
rm -rf ${tmp}/${lcms2_srcdir}

}
