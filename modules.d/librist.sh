#!/bin/bash

# Functions for detecting and building librist
echo 'Loading librist...'

function libristInstalled() {
# Cannot evaulate if we dont have modules installed
if [ ! -f /etc/profile.d/modules.sh ] ; then
  return 1
fi
# Load modules if not loaded already
if [ -z "${MODULEPATH}" ] ; then
  source /etc/profile.d/modules.sh
fi 
# If modules is OK, then check librist
if [ ! -f ${MODULEPATH}/librist/${1} ] ; then
  return 1
else
  return 0
fi
}

function check_librist() {
if libristInstalled ${1}; then
  echo "librist ${1} is installed."
else
  build_librist ${1}
fi
}

function build_librist() {

# Get desired version number to install
librist_v=${1}
if [ -z "${librist_v}" ] ; then
  echo "ERROR: No librist version specified!"
  exit 2
fi

librist_srcdir=librist-${librist_v}
librist_prefix=${opt}/librist-${librist_v}

echo "Installing librist ${librist_v}..."

case ${librist_v} in
  0.2.0-RC6) # 2021-03-28
   librist_srcdir=librist-v${librist_v}
   librist_meson_ver=0.57.1 # 2021-02-20
   librist_ninja_ver=1.10.2 # 2020-11-28
   librist_python_ver=3.9.2 # 2021-02-19
   librist_cmake_ver=3.20.0 # 2021-03-23
   librist_mbedtls_ver=2.26.0 # 2021-03-12
  ;;
  *)
   echo "ERROR: Need review for librist ${librist_v}"
   exit 4
   ;;
esac

check_modules
check_mbedtls ${librist_mbedtls_ver}
check_ninja ${librist_ninja_ver}
check_python ${librist_python_ver}
check_cmake ${librist_cmake_ver}
if [ "${librist_meson_ver}" == "0.57.1" ] && [ "${librist_python_ver}" == "3.9.2" ] ; then
  check_p3wheel ${librist_python_ver} wheel 0.36.2
fi
check_p3wheel ${librist_python_ver} meson ${librist_meson_ver}

downloadPackage ${librist_srcdir}.tar.gz

cd ${tmp}

if [ -d ${tmp}/${librist_srcdir} ] ; then
  rm -rf ${tmp}/${librist_srcdir}
fi

cd ${tmp}
tar xvfz ${pkg}/${librist_srcdir}.tar.gz
mkdir -pv ${tmp}/${librist_srcdir}/build
cd ${tmp}/${librist_srcdir}/build

if [ ${debug} -gt 0 ] ; then
  echo '>> Unzip complete'
  read k
fi

module purge
module load mbedtls/${librist_mbedtls_ver}
module load Python/${librist_python_ver}
module load ninja/${librist_ninja_ver}
module load cmake/${librist_cmake_ver}

config="meson setup --prefix=${librist_prefix} .."

if [ ${debug} -gt 0 ] ; then
  meson --help
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
ninja

if [ ! $? -eq 0 ] ; then
  exit 4
fi
if [ ${debug} -gt 0 ] ; then
  echo '>> Build complete'
  read k
fi

# librist testsuite?
#if [ ${run_tests} -gt 0 ] ; then
#  make check
#  echo '>> Tests complete'
#  read k
#fi

ninja install
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
mkdir -pv ${MODULEPATH}/librist
cat << eof > ${MODULEPATH}/librist/${librist_v}
#%Module

proc ModulesHelp { } {
   puts stderr "Puts librist-${librist_v} into your environment"
}

set VER ${librist_v}
set PKG ${opt}/librist-\$VER

module-whatis   "Loads librist-${librist_v}"
conflict librist
module load mbedtls/${librist_mbedtls_ver}
prereq mbedtls/${librist_mbedtls_ver}

prepend-path PATH \$PKG/bin
prepend-path CPATH \$PKG/include
prepend-path C_INCLUDE_PATH \$PKG/include
prepend-path CPLUS_INCLUDE_PATH \$PKG/include
prepend-path LD_LIBRARY_PATH \$PKG/lib
prepend-path PKG_CONFIG_PATH \$PKG/lib/pkgconfig

eof

cd ${root}
rm -rf ${tmp}/${librist_srcdir}

}
