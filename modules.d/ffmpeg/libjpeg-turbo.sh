#!/bin/bash

# Functions for detecting and building libjpeg-turbo
echo 'Loading libjpeg-turbo...'

function get_libjpegturbo_library() {
case ${1} in
  1.5.2)
    echo libjpeg.so.62.2.0
  ;;
  2.0.3)
    echo libjpeg.so.62.3.0
  ;;
  2.0.4)
    echo libjpeg.so.62.3.0
  ;;
  2.0.5)
    echo libjpeg.so.62.3.0
  ;;
  2.0.6)
    echo libjpeg.so.62.3.0
  ;;
  2.1.1)
    echo libjpeg.so.62.3.0
  ;;
  2.1.2)
    echo libjpeg.so.62.3.0
  ;;
  *)
    echo ''
  ;;
esac
}

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
  echo "ERROR: No libjpeg-turbo version specified!"
  exit 2
fi

case ${libjpegturbo_v} in
  1.5.2) # 2017-08-09
   libjpegturbo_cmake_ver=3.9.0  # 2017-07-18
   libjpegturbo_nasm_ver=2.13.01 # 2017-05-01
   libjpegturbo_use_cmake=0      # In libjpeg-turbo 1.5.2, cmake is only for windows builds; must use autotools on unix.
  ;;
  2.0.3) # 2019-09-04
   libjpegturbo_cmake_ver=3.15.3 # 2019-09-04
   libjpegturbo_nasm_ver=2.14.02 # 2018-12-26
   libjpegturbo_use_cmake=1      # In libjpeg-turbo 2.0.3, cmake is used for all platforms, autotools not supported.
  ;;
  2.0.4) # 2019-12-31
   libjpegturbo_cmake_ver=3.16.2 # 2019-12-19
   libjpegturbo_nasm_ver=2.14.02 # 2018-12-26
   libjpegturbo_use_cmake=1      # In libjpeg-turbo 2.0.4, cmake is used for all platforms, autotools not supported.
  ;;
  2.0.5) # 2020-06-23
   libjpegturbo_cmake_ver=3.17.3 # 2020-05-28
   libjpegturbo_nasm_ver=2.14.02 # 2018-12-26
   libjpegturbo_use_cmake=1      # In libjpeg-turbo 2.0.4, cmake is used for all platforms, autotools not supported.
  ;;
  2.0.6) # 2020-11-16
   libjpegturbo_cmake_ver=3.18.4 # 2020-10-06
   libjpegturbo_nasm_ver=2.15.05 # 2020-08-28
   libjpegturbo_use_cmake=1      # In libjpeg-turbo 2.0.4, cmake is used for all platforms, autotools not supported.
  ;;
  2.1.1) # 2021-08-09
   libjpegturbo_cmake_ver=3.21.1 # 2021-07-27
   libjpegturbo_nasm_ver=2.15.05 # 2020-08-28
   libjpegturbo_use_cmake=1      # In libjpeg-turbo 2.0.4, cmake is used for all platforms, autotools not supported.
  ;;
  2.1.2) # 2021-11-18
   libjpegturbo_cmake_ver=3.22.0 # 2021-11-18
   libjpegturbo_nasm_ver=2.15.05 # 2020-08-28
   libjpegturbo_use_cmake=1      # In libjpeg-turbo 2.0.4, cmake is used for all platforms, autotools not supported.
  ;;
  *)
   echo "ERROR: Review needed for libjpeg-turbo ${libjpegturbo_v}"
   exit 4 # Please review
  ;;
esac

echo "Installing libjpeg-turbo ${libjpegturbo_v}..."
libjpegturbo_srcdir=libjpeg-turbo-${libjpegturbo_v}

check_modules
if [ ${libjpegturbo_use_cmake} -gt 0 ] ; then
  check_cmake ${libjpegturbo_cmake_ver}
fi
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
if [ ${libjpegturbo_use_cmake} -gt 0 ] ; then
  module load cmake/${libjpegturbo_cmake_ver}
fi
module load nasm/${libjpegturbo_nasm_ver}

if [ ${libjpegturbo_use_cmake} -gt 0 ] ; then

if [ ! -d ${tmp}/${libjpegturbo_srcdir}/build ] ; then
  mkdir -v ${tmp}/${libjpegturbo_srcdir}/build
fi
cd ${tmp}/${libjpegturbo_srcdir}/build

if [ ${debug} -gt 0 ] ; then
  echo ''
  module list
  echo ''
  echo cmake -L -G \"Unix Makefiles\" \
      -DCMAKE_INSTALL_PREFIX=${opt}/libjpeg-turbo-${libjpegturbo_v} ..
  read k
fi

cmake -L -G "Unix Makefiles" \
      -DCMAKE_INSTALL_PREFIX=${opt}/libjpeg-turbo-${libjpegturbo_v} ..
else

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

fi
if [ ${debug} -gt 0 ] ; then
  echo '>> Configure complete'
  read k
  if [ "${libjpegturbo_use_cmake}" -lt 1 ] ; then
    echo 'NOTE: You are going to see a few messages that look concerning, like this:'
    echo ' libtool: ignoring unknown tag NASM'
    echo
    echo "It's normal.  You can ignore it.  simd/Makefile.am passes --tag NASM to"
    echo "libtool in order to support older versions of libtool, but unfortunately"
    echo "newer versions of libtool generate that warning.  At some point, we may"
    echo "require a newer minimum libtool version, in which case I can remove the"
    echo "--tag argument.  Another solution might be to detect the libtool version"
    echo "in simd/Makefile.am and include the --tag argument to libtool only if"
    echo "using an older version.  I don't have time to look into that right now,"
    echo "though."
    echo
    echo ">> Press enter to acknowledge"
    read k
  fi
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
